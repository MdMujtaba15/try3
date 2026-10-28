/* Liability SCRIPT 4: Import and Prep Python Output FINAL                      */

options validvarname=v7;

/* STANDARDIZED JOIN-KEY HELPER  */

%macro make_date_key(data=, out=, id=EMP_ID, date=PayPeriodEnd_dt,
			idkey=EMP_ID_KEY, datekey=PAYPERIOD_KEY);

	data &out.;
		set &data.;
		length &idkey $64 _date_text $64;
		_date_text = strip(vvalue(&date));
		&idkey = upcase(strip(vvalue(&id)));
		&datekey = input(_date_text, ?? yymmdd8.);

		if missing(&datekey) then
			&datekey = input(_date_text, ?? mmddyy10.);

		if missing(&datekey) then
			&datekey = input(_date_text, ?? anydtdte.);

		if missing(&datekey) then
			do;
				_date_num = input(_date_text, ?? best32.);

				/* Fallback for an unformatted numeric SAS date value. */
				if not missing(_date_num) and 0 <= _date_num <= 100000 then
					&datekey = _date_num;
			end;

		format &datekey date9.;
		drop _date_text _date_num;
	run;

%mend make_date_key;

/* IMPORT SHAP VALUES */

%macro ImportCustom();
	%if &flag. = 1 %then
		%do;

			proc import
				datafile="/ere/local/shared/actuarial/Share/Claims/WPC/Liability/executable/Output/model_shap.csv"
				dbms=csv
				replace
				out=PYTHONRAW;
				guessingrows=max;
			run;

		%end;
	%else
		%do;

			proc import
				datafile="&output_path_csv/model_shap.csv"
				dbms=csv
				replace
				out=PYTHONRAW;
				guessingrows=max;
			run;

		%end;
%mend ImportCustom;

%ImportCustom();

/* STANDARDIZE SHAP VARIABLE NAMES */

data PYTHONRAW;
	set PYTHONRAW;
	rename
		__InjuryLevelIncident___=InjuryLevelIncident
		__legal_ind___=legal_ind
		__EXPSR_TIER_DC_grp___=EXPSR_TIER_DC_grp
		__CT_SCAN_IN___=CT_SCAN_IN
		__TIER_TYP_DC_grp___=TIER_TYP_DC_grp
		__AGGR_LMT_Ind___=AGGR_LMT_Ind
		__ContactCount___=ContactCount
		__FLG_TYP_DC_Ind___=FLG_TYP_DC_Ind
		__PRIM_BODY_PART_TYP_Ind___=PRIM_BODY_PART_TYP_Ind
		__AdjusterRole___=AdjusterRole
		__USR_RPT_BRNCH_DC___=RPT_ENTITY
		__INSD_FLT_TYP_DC_grp___=INSD_FLT_TYP_DC_grp
		__frst_iso_send_dt_Ind___=frst_iso_send_dt_Ind
		__SPCL_INVSTN_UNT_STT_DC___=SPCL_INVSTN_UNT_STT_DC
		__FNOL_SRVY_IN___=FNOL_SRVY_IN
		__TORT_OPT_Full_Ind___=TORT_OPT_Full_Ind
		__EXPSR_TYP_DC_grp___=EXPSR_TYP_DC_grp
		__LIEN_IN___=LIEN_IN
		__AutoMidHighComplexity_Ind___=AutoMidHighComplexity_Ind
		__LC_CollisionMultiVeh___=LC_CollisionMultiVeh
		__HIT_AND_RUN_IN___=HIT_AND_RUN_IN
		__Out_Of_State_Ind___=Out_Of_State_Ind
		__HO_PNTV_DMG_CNT_IN___=HO_PNTV_DMG_CNT_IN
		__Report_Lag___=Report_Lag
		__Contact_Government___=Contact_Government
		__LC_Weather___=LC_Weather
		__Claimant_Under17_ind___=Claimant_Under17_ind
		__Contact_Doctor___=Contact_Doctor
		__LC_TheftOfEntireVehicle___=LC_TheftOfEntireVehicle
		__baseline_mean___=baseline_mean;
run;

/* Confirm that the imported SHAP data has the required scoring columns. */

proc contents data=PYTHONRAW varnum;
run;

/* CREATE SHAP GROUPINGS */

data python2;
	set pythonraw;
	drop var1;

	Claim = sum(
		TIER_TYP_DC_grp,
		ContactCount,
		INSD_FLT_TYP_DC_grp,
		AutoMidHighComplexity_Ind,
		LC_CollisionMultiVeh,
		Out_Of_State_Ind,
		Report_Lag,
		Contact_Government,
		LC_Weather,
		Claimant_Under17_ind,
		LC_TheftOfEntireVehicle
		);

	Exposure = sum(
		EXPSR_TIER_DC_grp,
		AGGR_LMT_Ind,
		AdjusterRole,
		RPT_ENTITY,
		FNOL_SRVY_IN,
		TORT_OPT_Full_Ind,
		EXPSR_TYP_DC_grp,
		LIEN_IN
		);

	Medical = sum(
		InjuryLevelIncident,
		CT_SCAN_IN,
		PRIM_BODY_PART_TYP_Ind,
		Contact_Doctor
		);

	Investigation = sum(
		legal_ind,
		FLG_TYP_DC_Ind,
		frst_iso_send_dt_Ind,
		SPCL_INVSTN_UNT_STT_DC,
		HIT_AND_RUN_IN,
		HO_PNTV_DMG_CNT_IN
		);

	shap_pred = sum(
		baseline_mean,
		Claim,
		Exposure,
		Medical,
		Investigation
		);
	check = round(shap_pred - pred, .001);
run;

proc means data=python2 nway noprint missing;
	class check;
	var Contact_Government;
	output out=test(drop=_type_) sum=;
run;

/* IMPORT COMPLETED EXPOSURES */

proc import
	datafile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Liability/Workload SAS programs/History Liability Completed Exposure.xlsx"
	dbms=xlsx
	replace
	out=Exposures_Completed;
	getnames=yes;
run;

%changeColFormat2Char(
    Exposures_Completed,
    CLM_NR|CLM_KEY|JURIS_STATE_DC|LOB|WRKLD_HIST_DC|
    YearMon|EMP_NM|EMP_ID|RPT_ENTITY|REGION|
    ADJ_GRP_DC|JOB_TTL_FULL|JOB_TTL|SPVS_NM|SPVS_EMP_ID|WorkType|EXPSR_TYP_DC|
    FRST_NM|LST_NM|PolicyST|Source|Status|
    PayPeriodEnd|EmpIDPPE|USR_NTRL_ID,
    $50.
);
%changeColFormat2Num(Exposures_Completed, LOSS_DT|CLM_CRT_DT|STRT_DT|END_DT|CLS_DT|CLM_CNT|CLM_KEY_CNT|EXPSR_NTRL_ID|INCID_NTRL_ID|CLMT_ID, Best8.2);


/* IMPORT NEW EXPOSURES */

proc import
	datafile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Liability/Workload SAS programs/History Liability New Exposure.xlsx"
	dbms=xlsx
	replace
	out=Exposures_New;
	getnames=yes;
run;

%changeColFormat2Char(
    Exposures_New,
    CLM_NR|CLM_KEY|JURIS_STATE_DC|LOB|WRKLD_HIST_DC|
    YearMon|EMP_NM|EMP_ID|RPT_ENTITY|REGION|
    ADJ_GRP_DC|JOB_TTL_FULL|JOB_TTL|SPVS_NM|SPVS_EMP_ID|WorkType|
    EXPSR_TYP_DC|FRST_NM|LST_NM|PolicyST|Source|Status|
    PayPeriodEnd|EmpIDPPE|LossSt|USR_NTRL_ID,
    $50.
);
%changeColFormat2Num(Exposures_New, LOSS_DT|CLM_CRT_DT|STRT_DT|END_DT|CLS_DT|CLM_CNT|CLM_KEY_CNT|EXPSR_NTRL_ID|INCID_NTRL_ID|CLMT_ID, Best8.2);


/* NORMALIZE PAYPERIODEND BEFORE STACKING THE TWO EXPOSURE FILES */
/* This prevents the character/numeric PayPeriodEnd conflict. */

data Exposures_Completed_fix;
	set Exposures_Completed;
	length PayPeriodEnd_char $50;
	PayPeriodEnd_char = strip(vvalue(PayPeriodEnd));
	drop PayPeriodEnd;
	rename PayPeriodEnd_char = PayPeriodEnd;
run;

data Exposures_New_fix;
	set Exposures_New;
	length PayPeriodEnd_char $50;
	PayPeriodEnd_char = strip(vvalue(PayPeriodEnd));
	drop PayPeriodEnd;
	rename PayPeriodEnd_char = PayPeriodEnd;
run;

/* STACK EXPOSURES AND CREATE STANDARDIZED KEYS */

data monthend_Liab_Exposure;
	length drpno $100 PayPeriodString $50;
	set Exposures_Completed_fix
		Exposures_New_fix;
	drpno = catx(
		'-',
		strip(vvalue(CLM_NR)),
		strip(vvalue(EXPSR_NTRL_ID)),
		strip(vvalue(EMP_ID))
		);
	PayPeriodString = compress(strip(PayPeriodEnd));

	/* Handle YYYYMMDD and standard date strings. */
	payperioddate = input(PayPeriodString, ?? yymmdd8.);

	if missing(payperioddate) then
		payperioddate = input(PayPeriodString, ?? anydtdte.);
	format payperioddate mmddyy10.;
run;

/* MERGE EXPOSURE DATA WITH SHAP SCORES */

proc sql;
	create table for_report as
		select
			a.drpno,
			a.Status,
			a.EMP_NM as ADJUSTERNAME,
			a.EMP_ID as ADJUSTERNR,
			a.JOB_TTL_FULL as ADJPOSITIONTITLE,
			a.RPT_ENTITY as ADJUSTERREPORTINGBRANCH,
			a.WorkType,
			a.payperioddate,
			max(b.pred, 0) as model_elaps,
			b.Claim,
			b.Exposure,
			b.Medical,
			b.Investigation
		from monthend_Liab_Exposure as a
			left join python2 as b
				on compress(a.drpno) = compress(b.drpno);
quit;

proc means data=for_report nway noprint missing;
	class Claim;
	var payperioddate;
	output out=test(drop=_type_) sum=;
run;

/* IMPORT THE UPDATED LIABILITY TEMPLATE */

proc import
	datafile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Adj Prod by Liability_Template.xlsx"
	dbms=xlsx
	replace
	out=Liability_Template;
	getnames=yes;
run;

/* CREATE STANDARDIZED KEYS BEFORE THE TEMPLATE JOIN */

data for_report_keyed;
	set for_report;
	length ADJUSTER_KEY $64;
	ADJUSTER_KEY = upcase(strip(vvalue(ADJUSTERNR)));
	PAYPERIOD_KEY = payperioddate;
	format PAYPERIOD_KEY date9.;
run;

%make_date_key(data=Liability_Template, out=Liability_Template_keyed,
	id=EMP_ID, date=PayPeriodEnd_dt,
	idkey=EMP_ID_KEY, datekey=PAYPERIOD_KEY);

/* MERGE TEMPLATE FIELDS; all joins now compare like-typed keys. */

proc sql;
	create table for_report as
		select a.*, b.REGION, b.RPT_ENTITY, b.JOB_TTL_FULL
			from for_report_keyed as a
				left join Liability_Template_keyed as b
					on a.ADJUSTER_KEY = b.EMP_ID_KEY
					and a.PAYPERIOD_KEY = b.PAYPERIOD_KEY;
quit;

/* REMOVE RECORDS WITHOUT REQUIRED MODEL/TEMPLATE DATA */

data for_report;
	set for_report;

	if missing(JOB_TTL_FULL) then
		delete;

	if missing(payperioddate) then
		delete;

	if missing(Claim) then
		delete;

	if RPT_ENTITY = 'Fort Wayne' then
		RPT_ENTITY = 'Indiana';
	else if RPT_ENTITY = 'Hagerstown' then
		RPT_ENTITY = 'Silver Spring';
	else if RPT_ENTITY = 'Johnstown' then
		RPT_ENTITY = 'Murrysville';
	else if RPT_ENTITY = 'Waynesboro' then
		RPT_ENTITY = 'Roanoke';
run;

/* ADJUSTER AVERAGES */

proc means data=for_report noprint nway missing;
	class ADJUSTERNR JOB_TTL_FULL RPT_ENTITY WorkType payperioddate;
	var model_elaps Claim Exposure Medical Investigation;
	output out=avg_adj(drop=_type_) mean=;
	where not missing(ADJUSTERNR);
run;

/* OVERALL AVERAGE BY POSITION AND WORK TYPE */

proc means data=for_report noprint nway missing;
	class JOB_TTL_FULL WorkType;
	var model_elaps Claim Exposure Medical Investigation;
	output out=avg_adjposition(drop=_type_) mean=;
	where not missing(ADJUSTERNR);
run;

/* BUILD ADJUSTER REPORT */

proc sql;
	create table ind_report as
		select
			a.ADJUSTERNR,
			a.JOB_TTL_FULL,
			a.RPT_ENTITY,
			a.WorkType,
			a.payperioddate,
			year(a.payperioddate) as year,
			a.model_elaps as adj_avg,
			a._freq_ as records,
			a.Claim,
			a.Exposure,
			a.Medical,
			a.Investigation,
			b.model_elaps as model_elaps_roll,
			a.model_elaps / b.model_elaps as adj_to_cw
		from avg_adj as a
			left join avg_adjposition as b
				on a.JOB_TTL_FULL = b.JOB_TTL_FULL
				and a.WorkType = b.WorkType;
quit;

/* NORMALIZE ADJUSTMENTS */

proc sort data=ind_report;
	by JOB_TTL_FULL WorkType;
run;

proc rank data=ind_report out=ind_report groups=100;
	var adj_to_cw;
	by JOB_TTL_FULL WorkType;
	ranks adj_to_cw_n;
run;

data ind_report;
	set ind_report;
	z_score = max(min(adj_to_cw_n / 100, 0.99), 0.01);
	norm = quantile('NORMAL', z_score);
	norm_adj = round(1 + norm * 0.05, 0.01);
run;

/* RANK THE FOUR MODEL FLAGS */

proc rank data=ind_report out=ind_report groups=4;
	var Claim;
	by JOB_TTL_FULL WorkType;
	ranks Claim_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var Exposure;
	by JOB_TTL_FULL WorkType;
	ranks Exposure_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var Medical;
	by JOB_TTL_FULL WorkType;
	ranks Medical_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var Investigation;
	by JOB_TTL_FULL WorkType;
	ranks Investigation_r;
run;

/* Keys used by template, branch, region and Qlik joins. */

data ind_report;
	set ind_report;
	length ADJUSTER_KEY $64;
	ADJUSTER_KEY = upcase(strip(vvalue(ADJUSTERNR)));
	PAYPERIOD_KEY = payperioddate;
	format PAYPERIOD_KEY date9.;
run;

/* SPLIT TEMPLATE INTO INJURIES AND NON-INJURIES */

data Liability_Template_Injuries;
	set Liability_Template;
	length WorkType $12;
	WorkType = 'Injuries';
run;

data Liability_Template_NonInjuries;
	set Liability_Template;
	length WorkType $12;
	WorkType = 'Non-Injuries';
run;

data ind_all;
	set Liability_Template_Injuries Liability_Template_NonInjuries;
run;

%make_date_key(data=ind_all, out=ind_all_keyed,
	id=EMP_ID, date=PayPeriodEnd_dt,
	idkey=EMP_ID_KEY, datekey=PAYPERIOD_KEY);

/* MERGE MODEL ADJUSTMENTS INTO TEMPLATE using standardized keys. */

proc sql;
	create table ind_all as
		select a.*, b.norm_adj, b.Claim_r, b.Exposure_r, b.Medical_r, b.Investigation_r
			from ind_all_keyed as a
				left join ind_report as b
					on a.EMP_ID_KEY = b.ADJUSTER_KEY
					and a.PAYPERIOD_KEY = b.PAYPERIOD_KEY
					and a.WorkType = b.WorkType;
quit;

/* Diagnostic counts before the existing default-to-1 rules are applied. */

proc sql;
	select count(*) as TEMPLATE_WORKTYPE_ROWS from ind_all;
	select count(*) as ROWS_WITHOUT_MODEL_ADJUSTMENT
		from ind_all where missing(norm_adj);
quit;

/* OUTPUT ADJUSTER-LEVEL DATA */

data ind_out(
	keep=WorkType EMP_ID EMP_ID_KEY JOB_TTL_FULL RPT_ENTITY
	PayPeriodEnd_dt PAYPERIOD_KEY norm_adj Claim_r Exposure_r Medical_r Investigation_r
	);
	retain
		WorkType EMP_ID EMP_ID_KEY JOB_TTL_FULL RPT_ENTITY
		PayPeriodEnd_dt PAYPERIOD_KEY norm_adj Claim_r Exposure_r Medical_r Investigation_r;
	set ind_all;

	if missing(norm_adj) then
		norm_adj = 1;

	if missing(Claim_r) then
		Claim_r = 1;

	if missing(Exposure_r) then
		Exposure_r = 1;

	if missing(Medical_r) then
		Medical_r = 1;

	if missing(Investigation_r) then
		Investigation_r = 1;
run;

/* BRANCH-LEVEL WEIGHTED ADJUSTMENTS */

proc means data=ind_all noprint nway missing;
	class WorkType JOB_TTL_FULL RPT_ENTITY PAYPERIOD_KEY;
	var norm_adj;
	weight Total_Hours;
	output out=br_adjs(drop=_freq_ _type_) mean=;
run;

data br_adjs;
	set br_adjs;
	norm_adj = round(norm_adj, 0.01);

	if missing(norm_adj) then
		norm_adj = 1;
run;

/* REGION-LEVEL WEIGHTED ADJUSTMENTS */
/* Include REGION in CLASS so the later REGION joins have the correct key. */

proc means data=ind_all noprint nway missing;
	class WorkType JOB_TTL_FULL REGION PAYPERIOD_KEY;
	var norm_adj;
	weight Total_Hours;
	output out=regn_adjs(drop=_freq_ _type_) mean=;
run;

data regn_adjs;
	set regn_adjs;
	norm_adj = round(norm_adj, 0.01);

	if missing(norm_adj) then
		norm_adj = 1;
run;

/* QLIK FILES */

/* SPLIT ADJUSTER OUTPUT */

data AVG_ADJ_Injuries AVG_ADJ_NonInjuries Error;
	set ind_out;

	if WorkType = 'Injuries' then
		output AVG_ADJ_Injuries;
	else if WorkType = 'Non-Injuries' then
		output AVG_ADJ_NonInjuries;
	else output Error;
run;

/* SPLIT BRANCH OUTPUT */

data AVG_BRANCH_Injuries AVG_BRANCH_NonInjuries Error2;
	set br_adjs;

	if WorkType = 'Injuries' then
		output AVG_BRANCH_Injuries;
	else if WorkType = 'Non-Injuries' then
		output AVG_BRANCH_NonInjuries;
	else output Error2;
run;

/* SPLIT REGION OUTPUT */

data AVG_REGION_Injuries AVG_REGION_NonInjuries Error3;
	set regn_adjs;

	if WorkType = 'Injuries' then
		output AVG_REGION_Injuries;
	else if WorkType = 'Non-Injuries' then
		output AVG_REGION_NonInjuries;
	else output Error3;
run;

/* Standardize employee and pay-period keys once for both Qlik outputs. */

%make_date_key(data=LiabAdj.hcoutput, out=hcoutput_keyed,
	id=EMP_ID, date=payperioddate,
	idkey=EMP_ID_KEY, datekey=PAYPERIOD_KEY);

/* BUILD QLIK SUPERFILE. */

proc sql;
	create table qlik_final as
		select
			a.REGION,
			a.RPT_ENTITY,
			a.SPVS_EMP_ID,
			a.SPVS_NM,
			a.JOB_TTL_FULL,
			a.JOB_TTL,
			a.EMP_ID,
			a.EMP_NM,
			a.MaskEmpl,
			a.DISCIPLINE,
			a.DISC_SEC,
			a.WRK_CLASS,
			a.LEADER_NM,
			a.LEADER_EMP_ID,
			a.PRIM_ROL_NM,
			a.PayperiodEnd,
			a.EmpIDPPE,
			a.PayperiodEnd_dt,
			a.EmpIDPPE_dt,
			year(a.PAYPERIOD_KEY) as Year,
			month(a.PAYPERIOD_KEY) as Month,
			a.Total_Hours,
			a.TotalRegHrsPaid,
			a.TotalOTHrsPaid,
			a.TotalPTOHrsPaid,
			a.TotalOffSiteBus,
			a.OldClaims,
			a.NewInjuryExposures,
			a.OpenInjuryExposures,
			a.CompletedInjuryExposures,
			a.NewNonInjuryExposures,
			a.OpenNonInjuryExposures,
			a.CompletedNonInjuryExposures,

			b.norm_adj as Norm_adj_injuries,
			b.Claim_r as Claim_r_injuries,
			b.Exposure_r as Exposure_r_injuries,
			b.Medical_r as Medical_r_injuries,
			b.Investigation_r as Investigation_r_injuries,
			c.norm_adj as Adj_br_injuries,
			d.norm_adj as Adj_rgn_injuries,

			e.norm_adj as Norm_adj_noninjuries,
			e.Claim_r as Claim_r_noninjuries,
			e.Exposure_r as Exposure_r_noninjuries,
			e.Medical_r as Medical_r_noninjuries,
			e.Investigation_r as Investigation_r_noninjuries,
			f.norm_adj as Adj_br_noninjuries,
			g.norm_adj as Adj_rgn_noninjuries

		from hcoutput_keyed as a

		left join AVG_ADJ_Injuries as b
			on a.EMP_ID_KEY = b.EMP_ID_KEY
			and a.JOB_TTL_FULL = b.JOB_TTL_FULL
			and a.RPT_ENTITY = b.RPT_ENTITY
			and a.PAYPERIOD_KEY = b.PAYPERIOD_KEY

		left join AVG_BRANCH_Injuries as c
			on a.JOB_TTL_FULL = c.JOB_TTL_FULL
			and a.RPT_ENTITY = c.RPT_ENTITY
			and a.PAYPERIOD_KEY = c.PAYPERIOD_KEY

		left join AVG_REGION_Injuries as d
			on a.JOB_TTL_FULL = d.JOB_TTL_FULL
			and a.REGION = d.REGION
			and a.PAYPERIOD_KEY = d.PAYPERIOD_KEY

		left join AVG_ADJ_NonInjuries as e
			on a.EMP_ID_KEY = e.EMP_ID_KEY
			and a.JOB_TTL_FULL = e.JOB_TTL_FULL
			and a.RPT_ENTITY = e.RPT_ENTITY
			and a.PAYPERIOD_KEY = e.PAYPERIOD_KEY

		left join AVG_BRANCH_NonInjuries as f
			on a.JOB_TTL_FULL = f.JOB_TTL_FULL
			and a.RPT_ENTITY = f.RPT_ENTITY
			and a.PAYPERIOD_KEY = f.PAYPERIOD_KEY

		left join AVG_REGION_NonInjuries as g
			on a.JOB_TTL_FULL = g.JOB_TTL_FULL
			and a.REGION = g.REGION
			and a.PAYPERIOD_KEY = g.PAYPERIOD_KEY;
quit;

/* DEFAULT MISSING ADJUSTMENT FACTORS TO 1.0 */

data qlik_final;
	set qlik_final;
	array N[*]
		Norm_adj_injuries
		Adj_br_injuries
		Adj_rgn_injuries
		Norm_adj_noninjuries
		Adj_br_noninjuries
		Adj_rgn_noninjuries;

	do i = 1 to dim(N);
		if missing(N[i]) then
			N[i] = 1;
	end;

	drop i EMP_ID_KEY PAYPERIOD_KEY;
run;

/* BUILD QLIK ADJUSTMENTS INPUT */

proc sql;
	create table qa_completed as
		select
			a.EMP_ID,
			a.EMP_ID_KEY,
			a.PAYPERIOD_KEY,
			a.JOB_TTL_FULL,
			a.RPT_ENTITY,
			a.REGION,
			a.payperioddate,
			a.NewInjuryExposures,
			a.NewNonInjuryExposures,
			a.OpenInjuryExposures,
			a.OpenNonInjuryExposures,
			a.CompletedInjuryExposures,
			a.CompletedNonInjuryExposures
		from hcoutput_keyed as a;
quit;

proc sort data=qa_completed;
	by EMP_ID_KEY PAYPERIOD_KEY EMP_ID RPT_ENTITY REGION payperioddate JOB_TTL_FULL;
run;

/* TRANSPOSE EXPOSURE COUNTS */

proc transpose data=qa_completed out=qa_completed_w;
	by EMP_ID_KEY PAYPERIOD_KEY EMP_ID RPT_ENTITY REGION payperioddate JOB_TTL_FULL;
	var NewInjuryExposures -- CompletedNonInjuryExposures;
run;

/* CREATE EXPOSURE TYPE AND COUNT FIELDS */

data qa_completed_w;
	set qa_completed_w;
	length Exposure $12;
	length New Open Completed 8;

	if find(_NAME_, 'NonInjury') > 0 then
		Exposure = 'Non-Injuries';
	else Exposure = 'Injuries';

	if substr(_NAME_, 1, 3) = 'New' then
		New = COL1;
	else if substr(_NAME_, 1, 3) = 'Ope' then
		Open = COL1;
	else if substr(_NAME_, 1, 3) = 'Com' then
		Completed = COL1;
run;

/* SUMMARIZE COUNTS */

proc means data=qa_completed_w nway noprint missing;
	class Exposure JOB_TTL_FULL EMP_ID EMP_ID_KEY PAYPERIOD_KEY RPT_ENTITY payperioddate;
	var New Open Completed;
	output out=qa_completed_sum(drop=_type_) sum=;
run;

/* MERGE COUNTS WITH MODEL ADJUSTMENTS */

proc sql;
	create table qlik_adj1 as
		select
			a.Exposure,
			a.JOB_TTL_FULL as JOB_TTL,
			a.EMP_ID,
			a.RPT_ENTITY,
			a.payperioddate as Payperiodend_dt format=mmddyy10.,
			cats(strip(a.EMP_ID_KEY), put(a.PAYPERIOD_KEY, yymmddn8.)) as EmpIDPPE_dt length=64,
			a.New,
			a.Open,
			a.Completed,
			b.norm_adj,
			b.Claim_r,
			b.Exposure_r,
			b.Medical_r,
			b.Investigation_r
		from qa_completed_sum as a
			left join ind_out as b
				on a.EMP_ID_KEY = b.EMP_ID_KEY
				and a.RPT_ENTITY = b.RPT_ENTITY
				and a.JOB_TTL_FULL = b.JOB_TTL_FULL
				and a.PAYPERIOD_KEY = b.PAYPERIOD_KEY
				and a.Exposure = b.WorkType;
quit;

data qlik_adj1;
	set qlik_adj1;

	if missing(norm_adj) then
		norm_adj = 1;
run;

/* VALIDATION SNAPSHOT: verify output datasets exist and inspect exported columns. */
proc contents data=qlik_final varnum;
run;

proc contents data=qlik_adj1 varnum;
run;

proc sql;
	select count(*) as QLIK_FINAL_ROWS from qlik_final;
	select count(*) as QLIK_ADJ1_ROWS from qlik_adj1;
quit;

/* EXPORT OUTPUT FILES */
%macro ExportCustom();
	%if &flag. = 1 %then
		%do;

			proc export data=qlik_final
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Liability/executable/Output/QlikSuperfile_liab.xlsx"
				dbms=xlsx
				replace;
			run;

			proc export data=qlik_adj1
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Liability/executable/Output/QlikAdjustments_liab.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
	%else
		%do;

			proc export data=qlik_final
				outfile="&output_path_csv/QlikSuperfile_liab.xlsx"
				dbms=xlsx
				replace;
			run;

			proc export data=qlik_adj1
				outfile="&output_path_csv/QlikAdjustments_liab.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
%mend ExportCustom;

%ExportCustom();