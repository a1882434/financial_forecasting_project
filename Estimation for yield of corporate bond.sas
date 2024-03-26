/*** Task 2 - Sample and description statistics ***/
/** import data **/
PROC IMPORT OUT=work.assignment_sample_a 
		DATAFILE="/home/u63511963/BUSANA7001/Assignment/Sample_a.csv" DBMS=CSV 
		REPLACE;
	GETNAMES=yES;
	DATAROW=2;
RUN;

PROC IMPORT OUT=work.assignment_sample_b 
		DATAFILE="/home/u63511963/BUSANA7001/Assignment/Sample_b.csv" DBMS=CSV 
		REPLACE;
	GETNAMES=yES;
	DATAROW=2;
RUN;

/** remove duplicates **/
PROC SORT DATA=work.assignment_sample_a OUT=work.assignment_sample_a NODUPRECS;
	BY Bond_id;
RUN;

PROC SORT DATA=work.assignment_sample_b OUT=work.assignment_sample_b NODUPRECS;
	BY Issuer;
RUN;

/** merge the files using `bond_id' variable **/
/* SORT the data by bond_id before merging the DATA */
PROC SORT DATA=work.assignment_sample_a;
	BY bond_id;
RUN;

PROC SORT DATA=work.assignment_sample_b;
	BY bond_id;
RUN;

/* merge data by bond_id */
DATA work.assignment_bond;
	MERGE work.assignment_sample_b work.assignment_sample_a;
	BY bond_id;
RUN;

/** remove putable bonds from the sample **/
DATA work.assignment_bond;
	SET work.assignment_bond;

	IF putable="TRUE" THEN
		Delete;
RUN;

/** remove convertible bonds from the sample **/
DATA work.assignment_bond;
	SET work.assignment_bond;

	IF missing(convertible);
RUN;

/** remove observations with missing values of any variable **/
DATA work.assignment_bond;
	SET work.assignment_bond;

	/*drop missing value*/
	IF Coupon ne .;

	IF yield ne .;

	IF Maturity ne .;

	IF Amount_outstanding ne .;

	IF NOT missing(Issuer);

	IF NOT missing(callable);
RUN;

/** check for outliers and take necessary actions to deal with them **/
/* Identify outlier */
PROC UNIVARIATE DATA=work.assignment_bond;
	ID bond_id;
	VAR yield;
RUN;

/* remove the extreme outlier */
DATA work.assignment_bond;
	SET work.assignment_bond;

	IF bond_id=1338 THEN
		Delete;

	IF bond_id=1583 THEN
		Delete;

	IF bond_id=1133 THEN
		Delete;
RUN;

/* Identify any other outlier */
ODS OUTPUT sgplot=work.bond_boxplot;

PROC SGPLOT DATA=work.assignment_bond;
	VBOX yield;
RUN;

PROC PRINT DATA=work.bond_boxplot;

/* remove the outlier based on upper and lower inner fence*/
DATA work.bond_nooutlier;
	SET work.assignment_bond;

	IF yield > 3.5159 + (1.5*(3.5159-2.2843)) THEN
		Delete;

	IF yield < 2.2843 - (1.5*(3.5159-2.2843)) THEN
		Delete;
RUN;

/** remove bonds not denominated in US dollars **/
DATA work.bond_nooutlier;
	SET work.bond_nooutlier;

	IF currency NOT="US Dollar" THEN
		Delete;
RUN;

/** Create variables **/
/* 1. years to maturity */
DATA work.assignment_task2;
	SET work.bond_nooutlier;
	maturity2=(maturity-TODAY())/365;
RUN;

/* 2. amount outstanding in billions of USD */
DATA work.assignment_task2;
	SET work.assignment_task2;
	amount2=amount_outstanding/1000000000;
RUN;

/* 3. a natural logarithm of amount outstanding */
DATA work.assignment_task2;
	SET work.assignment_task2;
	ln_amount=LOG(amount_outstanding);
RUN;

/* 4. a dummy if a bond is callable */
DATA work.assignment_task2;
	SET work.assignment_task2;

	IF callable="TRUE" THEN
		dummy_callable=0;

	IF callable="FALSE" THEN
		dummy_callable=1;
RUN;

/* 5. a dummy if `seniority' is `Senior Unsecured' */
DATA work.assignment_task2;
	SET work.assignment_task2;
	dummy_seniority=1;

	IF seniority="Senior Unsecured" THEN
		dummy_seniority=0;
RUN;

/* 6. dummy variable for Moody's (Issue) credit rating */
DATA work.assignment_task2;
	SET work.assignment_task2;
	aaa_d=0;

	IF Moodys_cred_rat="Aaa" THEN
		aaa_d=1;
	aa_d=0;

	IF Moodys_cred_rat in ("Aa1" "Aa2" "Aa3") THEN
		aa_d=1;
	a_d=0;

	IF Moodys_cred_rat in ("A1" "A2" "A3") THEN
		a_d=1;
	baa_d=0;

	IF Moodys_cred_rat in ("Baa1" "Baa2" "Baa3") THEN
		baa_d=1;
	ba_d=0;

	IF Moodys_cred_rat in ("Ba1" "Ba2" "Ba3") THEN
		ba_d=1;
	b_d=0;

	IF Moodys_cred_rat in ("B1" "B2" "B3") THEN
		b_d=1;
	c_d=0;

	IF Moodys_cred_rat NOT in ("Aaa" "Aa1" "Aa2" "Aa3" "A1" "A2" "A3" "Baa1" 
		"Baa2" "Baa3" "Ba1" "Ba2" "Ba3" "B1" "B2" "B3") THEN
			c_d=1;
RUN;

/** DATA preparation for task 3 **/
/* Create dummy variable for market_of_issue */
DATA work.assignment_task2;
	SET work.assignment_task2;
	dummy_market_g=0;

	IF market_of_issue="Global (Other)" THEN
		dummy_market_g=1;
	dummy_market_d=0;

	IF market_of_issue="Domestic (Other)" THEN
		dummy_market_d=1;
	dummy_market_e=0;

	IF market_of_issue="Eurobond (Other)" THEN
		dummy_market_e=1;
RUN;

/* Create dummy cariable for sector */
DATA work.assignment_task2;
	SET work.assignment_task2;
	sector_1=0;

	IF sector="Aerospace" THEN
		sector_1=1;
	sector_2=0;

	IF sector="Airline" THEN
		sector_2=1;
	sector_3=0;

	IF sector="Automotive Manufacture" THEN
		sector_3=1;
	sector_4=0;

	IF sector="Beverage/Bottling" THEN
		sector_4=1;
	sector_5=0;

	IF sector="Building Products" THEN
		sector_5=1;
	sector_6=0;

	IF sector="Cable/Media" THEN
		sector_6=1;
	sector_7=0;

	IF sector="Chemicals" THEN
		sector_7=1;
	sector_8=0;

	IF sector="Conglomerate/DiversIFi" THEN
		sector_8=1;
	sector_9=0;

	IF sector="Consumer Products" THEN
		sector_9=1;
	sector_10=0;

	IF sector="Containers" THEN
		sector_10=1;

	/* 	Electronics sector is classified as dummy variable sector_11 */
	sector_11=0;

	IF sector="Electronics" THEN
		sector_11=1;
	sector_12=0;

	IF sector="Food Processors" THEN
		sector_12=1;
	sector_13=0;

	IF sector="Gaming" THEN
		sector_13=1;
	sector_14=0;

	IF sector="Health Care Facilities" THEN
		sector_14=1;
	sector_15=0;

	IF sector="Health Care Supply" THEN
		sector_15=1;
	sector_16=0;

	IF sector="Home Builders" THEN
		sector_16=1;
	sector_17=0;

	IF sector="Industrials - Other" THEN
		sector_17=1;
	sector_18=0;

	IF sector="Information/DATA Techn" THEN
		sector_18=1;
	sector_19=0;

	IF sector="Leisure" THEN
		sector_19=1;
	sector_20=0;

	IF sector="Lodging" THEN
		sector_20=1;
	sector_21=0;

	IF sector="Machinery" THEN
		sector_21=1;
	sector_22=0;

	IF sector="Metals/Mining" THEN
		sector_22=1;
	sector_23=0;

	IF sector="Pharmaceuticals" THEN
		sector_23=1;
	sector_24=0;

	IF sector="Publishing" THEN
		sector_24=1;
	sector_25=0;

	IF sector="Railroads" THEN
		sector_25=1;
	sector_26=0;

	IF sector="Restaurants" THEN
		sector_26=1;
	sector_27=0;

	IF sector="Retail Stores - Food/D" THEN
		sector_27=1;
	sector_28=0;

	IF sector="Retail Stores - Other" THEN
		sector_28=1;
	sector_29=0;

	IF sector="Service - Other" THEN
		sector_29=1;
	sector_30=0;

	IF sector="Telecommunications" THEN
		sector_30=1;
	sector_31=0;

	IF sector="Textiles/Apparel/Shoes 
		" THEN
		sector_31=1;
	sector_32=0;

	IF sector="Tobacco" THEN
		sector_32=1;
	sector_33=0;

	IF sector="Transportation - Other 
		" THEN
		sector_33=1;
	sector_34=0;

	IF sector="Vehicle Parts" THEN
		sector_34=1;
RUN;

/* Create natural logarithm of coupon */
DATA work.assignment_task2;
	SET work.assignment_task2;
	coupon_ln=LOG(coupon / 100);
RUN;

/** Summary Statistics after data wrangling **/
ODS OUTPUT Moments=work.moments;
ODS OUTPUT Quantiles=work.quantiles;
ODS OUTPUT BasicMeasures=work.bm;

PROC univariate DATA=work.assignment_task2 NORMAL;
	VAR yield;
	HISTOGRAM yield / NORMAL;
RUN;

PROC PRINT DATA=work.moments NOOBS;
RUN;

PROC PRINT DATA=work.quantiles NOOBS;
RUN;

PROC PRINT DATA=work.bm NOOBS;
RUN;

/* In normal distribution, outlier can be identified by standard devication and mean */
PROC SQL;
	SELECT LocValue label='Mean' INTO :mean FROM work.bm WHERE LocMeasure='Mean';
	SELECT VarValue label='Std Dev' INTO :std FROM work.bm WHERE 
		VarMeasure='Std Deviation';
QUIT;

DATA work.anyoutlier;
	SET work.assignment_task2;

	IF yield lt (&mean. - 3*&std.) or yield gt (&mean. + 3*&std.) THEN
		OUTPUT;
RUN;

PROC PRINT DATA=work.anyoutlier NOOBS;
RUN;
/* no outlier is identified */

/** Visualize data in chart **/
/* Frequency of market of issue */
TITLE1 "Frequency of market of issue";

PROC gchart DATA=work.assignment_task2;
	PIE market_of_issue / NOHEADING PERCENT=arrow VALUE=inside;
	RUN;
QUIT;

/* Frequency of bond Callable */
TITLE1 "Frequency of bond Callable";

PROC GCHART DATA=work.assignment_task2;
	PIE callable / NOHEADING PERCENT=arrow VALUE=inside;
	RUN;
QUIT;

/* Frequency of seniority */
PROC FREQ DATA=work.assignment_task2;
	TABLES seniority/OUT=seniority;
RUN;

PROC FORMAT;
	PICTURE per_sen (ROUND) 2-high='00.00%';
RUN;

TITLE1 "Frequency of seniority";

PROC gchart DATA=seniority;
	PIE seniority / SUMVAR=percent NOHEADING VALUE=outside;
	FORMAT percent per_sen.;
RUN;

/* Frequency of sector */
PROC FREQ DATA=work.assignment_task2;
	TABLES sector;
RUN;
TITLE1 'Frequency of sector';
PROC GCHART DATA=work.assignment_task2;
	VBAR sector;
	RUN;
QUIT;

/* Frequency of Moody's (Issue) credit rating */
PROC FREQ DATA=work.assignment_task2;
	TABLES moodys_cred_rat/OUT=rate;
RUN;

PROC FORMAT;
	PICTURE per_rate (ROUND) 0-high='00%';
RUN;

PATTERN1 COLOR=BIO;
AXIS1 LABEL=(a=90 "Frequency Percentage");
AXIS2 LABEL=("Moody's (Issue) credit rating");
TITLE1 "Frequency of Moody's (Issue) credit rating";

PROC GCHART DATA=rate;
	VBAR moodys_cred_rat / SUMVAR=percent RAXIS=axis1 MAXIS=axis2;
	FORMAT percent per_rate.;
RUN;

/* Scatter Plot of coupon and yield */
TITLE1 "Scatter Plot of coupon and yield";
PROC SGPLOT DATA=work.assignment_task2;
	SCATTER X=coupon Y=yield /MARKERATTRS=(SIZE=9 COLOR=VLIBG);
	ELLIPSE X=coupon Y=yield;
RUN;

/* Scatter Plot of outstanding amount and yield */
TITLE1 "Scatter Plot of outstanding amount and yield";
PROC SGPLOT DATA=work.assignment_task2;
	SCATTER X=ln_amount Y=yield /MARKERATTRS=(SIZE=9 COLOR=BILG);
	ELLIPSE X=ln_amount Y=yield;
RUN;

/* Scatter Plot of year of maturity and yield */
TITLE1 "Scatter Plot of year of maturity and yield";
PROC SGPLOT DATA=work.assignment_task2;
	SCATTER X=maturity2 Y=yield /MARKERATTRS=(SIZE=9 COLOR=LIPK);
	ELLIPSE X=maturity2 Y=yield;
RUN;


/*** Task 3 - Estimating yield for a hypothetical bond ***/
/* This step is not necessary, just personally perfer to have a seperate DATASET for assignment task3 */
DATA work.assignment_task3;
	SET work.assignment_task2;
RUN;

/** Linear Regression **/
PROC REG DATA=work.assignment_task3 OUTEST=reg_model;
	/* Regression model 1 */
	Reg_model_1: MODEL yield=maturity2 coupon amount2 dummy_market_g 
		dummy_market_d dummy_market_e dummy_callable dummy_seniority aaa_d aa_d a_d 
		baa_d ba_d b_d c_d sector_1 sector_2 sector_3 sector_4 sector_5 sector_6 
		sector_7 sector_8 sector_9 sector_10 sector_11 sector_12 sector_13 sector_14 
		sector_15 sector_16 sector_17 sector_18 sector_19 sector_20 sector_21 
		sector_22 sector_23 sector_24 sector_25 sector_26 sector_27 sector_28 
		sector_29 sector_30 sector_31 sector_32 sector_33 sector_34;

	/* Regression model 2 */
	Reg_model_2: MODEL yield=maturity2 coupon ln_amount dummy_market_g 
		dummy_market_d dummy_market_e dummy_callable dummy_seniority aaa_d aa_d a_d 
		baa_d ba_d b_d c_d sector_1 sector_2 sector_3 sector_4 sector_5 sector_6 
		sector_7 sector_8 sector_9 sector_10 sector_11 sector_12 sector_13 sector_14 
		sector_15 sector_16 sector_17 sector_18 sector_19 sector_20 sector_21 
		sector_22 sector_23 sector_24 sector_25 sector_26 sector_27 sector_28 
		sector_29 sector_30 sector_31 sector_32 sector_33 sector_34;

	/* Regression model 3 */
	Reg_model_3: MODEL yield=maturity2 coupon_ln ln_amount dummy_market_g 
		dummy_market_d dummy_market_e dummy_callable dummy_seniority aaa_d aa_d a_d 
		baa_d ba_d b_d c_d sector_1 sector_2 sector_3 sector_4 sector_5 sector_6 
		sector_7 sector_8 sector_9 sector_10 sector_11 sector_12 sector_13 sector_14 
		sector_15 sector_16 sector_17 sector_18 sector_19 sector_20 sector_21 
		sector_22 sector_23 sector_24 sector_25 sector_26 sector_27 sector_28 
		sector_29 sector_30 sector_31 sector_32 sector_33 sector_34;
	RUN;