/* Material Damage SAS Script 6 : Import and Prep Python Output v2 Superfile Fixes*/

%macro custom_infile();
	%if &flag. = 1 %then
		%do;

			data WORK.PYTHONRAW;
				infile "/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/model_out.csv" delimiter =
					',' MISSOVER DSD lrecl=32767 firstobs=2;
				informat VAR1 best32.;
				informat drpno $8.;
				informat pred best32.;
				informat USR_RPT_BRNCH_DC best32.;
				informat veh_age best32.;
				informat lien_lease best32.;
				informat veh_opr best32.;
				informat common_veh best32.;
				informat VEH_STYL_DC_grp best32.;
				informat vehicles_in_20mi best32.;
				informat br_pos_emp_count best32.;
				informat drivetime best32.;
				informat coll_pnt_grp best32.;
				informat DRVR_INSD_REL_TYP_DC best32.;
				informat LOB_grp best32.;
				informat SEL_APPR_TYP_DC best32.;
				informat monthc best32.;
				informat DirectRepairProgram best32.;
				informat MaterialDamageAdjuster best32.;
				informat IndependentAdjuster best32.;
				informat EstimateDeskReview best32.;
				informat PhotoAppraisal best32.;
				informat supplements best32.;
				informat has_rental best32.;
				informat baseline_mean best32.;
				format VAR1 best12.;
				format drpno $8.;
				format pred best12.;
				format USR_RPT_BRNCH_DC best12.;
				format veh_age best12.;
				format lien_lease best12.;
				format veh_opr best12.;
				format common_veh best12.;
				format VEH_STYL_DC_grp best12.;
				format vehicles_in_20mi best12.;
				format br_pos_emp_count best12.;
				format drivetime best12.;
				format coll_pnt_grp best12.;
				format DRVR_INSD_REL_TYP_DC best12.;
				format LOB_grp best12.;
				format SEL_APPR_TYP_DC best12.;
				format monthc best12.;
				format DirectRepairProgram best12.;
				format MaterialDamageAdjuster best12.;
				format IndependentAdjuster best12.;
				format EstimateDeskReview best12.;
				format PhotoAppraisal best12.;
				format supplements best32.;
				format has_rental best32.;
				format baseline_mean best12.;
				input
					VAR1
					drpno
					pred
					USR_RPT_BRNCH_DC
					veh_age
					lien_lease
					veh_opr
					common_veh
					VEH_STYL_DC_grp
					vehicles_in_20mi
					br_pos_emp_count
					drivetime
					coll_pnt_grp
					DRVR_INSD_REL_TYP_DC
					LOB_grp
					SEL_APPR_TYP_DC
					monthc
					DirectRepairProgram
					MaterialDamageAdjuster
					IndependentAdjuster
					EstimateDeskReview
					PhotoAppraisal
					supplements
					has_rental
					baseline_mean
				;
			run;

		%end;
	%else
		%do;

			data WORK.PYTHONRAW;
				infile "&output_path_csv/model_out.csv" delimiter =
					',' MISSOVER DSD lrecl=32767 firstobs=2;
				informat VAR1 best32.;
				informat drpno $8.;
				informat pred best32.;
				informat USR_RPT_BRNCH_DC best32.;
				informat veh_age best32.;
				informat lien_lease best32.;
				informat veh_opr best32.;
				informat common_veh best32.;
				informat VEH_STYL_DC_grp best32.;
				informat vehicles_in_20mi best32.;
				informat br_pos_emp_count best32.;
				informat drivetime best32.;
				informat coll_pnt_grp best32.;
				informat DRVR_INSD_REL_TYP_DC best32.;
				informat LOB_grp best32.;
				informat SEL_APPR_TYP_DC best32.;
				informat monthc best32.;
				informat DirectRepairProgram best32.;
				informat MaterialDamageAdjuster best32.;
				informat IndependentAdjuster best32.;
				informat EstimateDeskReview best32.;
				informat PhotoAppraisal best32.;
				informat supplements best32.;
				informat has_rental best32.;
				informat baseline_mean best32.;
				format VAR1 best12.;
				format drpno $8.;
				format pred best12.;
				format USR_RPT_BRNCH_DC best12.;
				format veh_age best12.;
				format lien_lease best12.;
				format veh_opr best12.;
				format common_veh best12.;
				format VEH_STYL_DC_grp best12.;
				format vehicles_in_20mi best12.;
				format br_pos_emp_count best12.;
				format drivetime best12.;
				format coll_pnt_grp best12.;
				format DRVR_INSD_REL_TYP_DC best12.;
				format LOB_grp best12.;
				format SEL_APPR_TYP_DC best12.;
				format monthc best12.;
				format DirectRepairProgram best12.;
				format MaterialDamageAdjuster best12.;
				format IndependentAdjuster best12.;
				format EstimateDeskReview best12.;
				format PhotoAppraisal best12.;
				format supplements best32.;
				format has_rental best32.;
				format baseline_mean best12.;
				input
					VAR1
					drpno
					pred
					USR_RPT_BRNCH_DC
					veh_age
					lien_lease
					veh_opr
					common_veh
					VEH_STYL_DC_grp
					vehicles_in_20mi
					br_pos_emp_count
					drivetime
					coll_pnt_grp
					DRVR_INSD_REL_TYP_DC
					LOB_grp
					SEL_APPR_TYP_DC
					monthc
					DirectRepairProgram
					MaterialDamageAdjuster
					IndependentAdjuster
					EstimateDeskReview
					PhotoAppraisal
					supplements
					has_rental
					baseline_mean
				;
			run;

		%end;
%mend custom_infile;

%custom_infile();

data python2;
	set pythonraw (drop=var1);
	nuisance = sum(USR_RPT_BRNCH_DC);
	type = SEL_APPR_TYP_DC;

	vehicle = sum(veh_age,lien_lease,  
		veh_opr,
		common_veh,
		VEH_STYL_DC_grp  
		);

	service_area = sum(vehicles_in_20mi,
		br_pos_emp_count,
		drivetime);

	incident = sum(coll_pnt_grp,
		DRVR_INSD_REL_TYP_DC,
		LOB_grp);

	appraisal = sum(monthc,
		DirectRepairProgram,  
		MaterialDamageAdjuster,
		IndependentAdjuster, 
		EstimateDeskReview, 
		PhotoAppraisal,
		supplements,
		has_rental);

	shap_pred = sum(baseline_mean
		,nuisance
		,type
		,vehicle
		,service_area
		,incident
		,appraisal);
	check = round(shap_pred - pred,.001);
run;

PROC SQL;
	CREATE TABLE for_report As
		Select a.svc_req_nr
			,A.SEL_APPR_TYP_DC
			,A.ADJ_NM	
			,A.USR_RPT_BRNCH_DC	
			,A.ADJ_POS_DC	
			/*,A.ADJ_GRP_DC	*/
        	/*,A.year	*/
        	/*,A.month	*/
	        /*, a.elaps2*/

	, datepart(a.EVNT_DT) as complete_dt format mmddyy10.
	, max(B.pred,0) as model_elaps
	,b.vehicle
	,b.service_area
	,b.incident
	,b.appraisal
	From mdl_curr.for_pythonscoring as A left join python2 as B
		/*			on a.clm_nr = b.clm_nr*/
	on compress(a.svc_req_nr) = compress(b.drpno)
	/* may need supervisor name too */
	;
QUIT;

/* append pay periods */
PROC SQL;
	CREATE TABLE for_report As
		Select A.*
			, B.payperiod
		From for_report as A left join src.payperiods as B
			on A.complete_dt >= B.paystart
			and A.complete_dt <= B.payend
	;
QUIT;

/* apply some filters  */
data for_report;
	set for_report;
	where not missing(usr_rpt_brnch_dc);

	/* count data does not split IA1 and IA2, so for summary */
	if ADJ_POS_DC in ('Material Damage Inside Adjuster I','Material Damage Inside Adjuster II') then
		ADJ_POS_DC = 'Inside Adjuster';
run;

/* decode name to adjuster number from hc data */
/*merge decode on to data */
PROC SQL;
	CREATE TABLE for_report As
		Select A.*
			, B.EMP_ID
		From for_report as A left join mdl_curr.adj_decode as B
			on compress(A.ADJ_NM) = compress(B.EMP_NM)
	;
QUIT;

/* take individual means early */
proc means data= for_report noprint nway missing;
	class SEL_APPR_TYP_DC EMP_ID ADJ_POS_DC USR_RPT_BRNCH_DC payperiod;
	var model_elaps vehicle service_area incident appraisal;
	output out= adj_mdl (drop = _type_ ) mean=;
	where not missing(EMP_ID);
run;

/* only keep ones with at least 5 of that service type for pay period  */
data adj_mdl;
	set adj_mdl;
	where _freq_ > 5;
run;

/* replace this with a rolling 12 months */
/*JOIN ON DATA WHERE CALENDAR DATE IN RIGHT WINDOW - CAREFUL WITH HOW YOU PLAY WITH DAYS AND SIGNS*/
/*create  UNIQUE COMBOS*/
proc sql;
	create table
		YE
	as select distinct
		SEL_APPR_TYP_DC,
		payperiod
	from
		adj_mdl
	;
quit;

proc sql;
	create table
		cwppd_roll
	as select distinct
		YE.SEL_APPR_TYP_DC,
		YE.payperiod,
		mean(model_elaps) as model_elaps_roll
	from YE left join adj_mdl b
		on YE.SEL_APPR_TYP_DC = b.SEL_APPR_TYP_DC
		AND b.payperiod > intnx('year',ye.payperiod,-1,'sameday')
		and  b.payperiod <= ye.payperiod
	group by
		YE.SEL_APPR_TYP_DC,
		YE.payperiod
	;
quit;

PROC SQL;
	CREATE TABLE ind_report As
		Select A.SEL_APPR_TYP_DC 
			, a.EMP_ID
			, a.ADJ_POS_DC 
			, a.USR_RPT_BRNCH_DC 
			, a.payperiod
			, year(a.payperiod) as year
			, a.model_elaps as adj_avg
			, a._freq_ as records
			, a.vehicle ,a.service_area ,a.incident ,a.appraisal
			, b.model_elaps_roll 
			, a.model_elaps/b.model_elaps_roll as adj_to_cw
		From adj_mdl as A left join cwppd_roll as B
			on A.SEL_APPR_TYP_DC = B.SEL_APPR_TYP_DC
			and A.payperiod = B.payperiod
	;
QUIT;

/* force adjustments to be normal */
proc sort data=ind_report;
	by sel_appr_typ_dc year;
run;

proc rank data=ind_report out=ind_report groups=100;
	var adj_to_cw;
	by sel_appr_typ_dc year;
	ranks adj_to_cw_n;
run;

data ind_report;
	set ind_report;
	z_score = max(min((adj_to_cw_n)/100,99),.01); /* 0 and 1 cannot be quantiles */
	norm = quantile('NORMAL',z_score);
	norm_adj = round(1+norm*.05,.01);
run;

/* rank the four flags */
proc rank data=ind_report out=ind_report groups=4;
	var vehicle;
	by sel_appr_typ_dc year;
	ranks vehicle_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var service_area;
	by sel_appr_typ_dc year;
	ranks service_area_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var incident;
	by sel_appr_typ_dc year;
	ranks incident_r;
run;

proc rank data=ind_report out=ind_report groups=4;
	var appraisal;
	by sel_appr_typ_dc year;
	ranks appraisal_r;
run;

data ind_report;
	set ind_report;
	length region $10.;

	if USR_RPT_BRNCH_DC = 'Columbus' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Roanoke' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Charlotte' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Silver Spring' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Hagerstown' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Tennessee' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Philadelphia' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Murrysville' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Harrisburg' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Wisconsin' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Erie' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Allentown' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Indiana' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'New York' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'West Virginia' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Richmond' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Pittsburgh' then
		region = 'Northeast';
	else if USR_RPT_BRNCH_DC = 'Raleigh' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Fort Wayne' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Illinois' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Canton' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Kentucky' then
		region = 'West';
	else if USR_RPT_BRNCH_DC = 'Waynesboro' then
		region = 'Southeast';
	else if USR_RPT_BRNCH_DC = 'Claims' then
		region = 'Claims';
run;

/* export - no longer transpose since need to keep details */
data ind_out;
	set ind_report;
	keep EMP_ID	
		USR_RPT_BRNCH_DC
		sel_appr_typ_dc	
		payperiod	
		ADJ_POS_DC
		norm_adj
		vehicle_r
		service_area_r
		incident_r
		appraisal_r;
run;

/* roll up to branch */
/* transpose, making all missings zeroes */
proc sort data=ind_report;
	by EMP_ID region USR_RPT_BRNCH_DC payperiod adj_pos_dc;
run;

proc transpose data=ind_report out=ind_report2 prefix=adj;
	by EMP_ID region USR_RPT_BRNCH_DC payperiod adj_pos_dc;
	id SEL_APPR_TYP_DC;
	var norm_adj;
run;

data ind_report2 (drop=i);
	set ind_report2;
	drop _NAME_;
	array N[*] adjDirectRepairProgram 
		adjMaterialDamageAdjuster	
		adjEstimateDeskReview	
		adjSalvage	
		adjIndependentAdjuster	
		adjPhotoAppraisal
		adjOpenShop	
	;

	do i=1 to hbound(N);
		if N[i]=. then
			N[i]=1;
	end;
run;

/* make matching position descriptions */
data ind_report2;
	set ind_report2;

	if adj_pos_dc = 'Material Damage Adjuster' then
		adj_pos_dc = 'Field Adjuster';
run;

/* merge to hours / counts data */
PROC SQL;
	CREATE TABLE ind_report3 As
		Select A.*
			,b.Direct_Repair_Program 
			,b.MDA_Services_Complete as Material_Damage_Adjuster	
			,b.Estimate_Desk_Review as Estimate_Desk_Review	
			,b.Salvage  	
			,b.Independent_Adjuster as Independent_Adjuster	
			,b.Photo_Appraisal as Photo_Appraisal
			,b.DimVal															

	, B.TotalRegHrsPaid as total_regular_hours_paid 
	From ind_report2 as A left join mdl_curr.hcoutput as B
		on A.EMP_ID = B.EMP_ID
		/*and a.adj_pos_dc = b.'Adj Position'n*/
        /*and A.USR_RPT_BRNCH_DC = B.'Adjuster Team Branch'n*/
	and A.payperiod = B.PayperiodEnd_dt
	;
QUIT;

/* roll up to branch using hours as weight */
proc means data= ind_report3 noprint nway missing;
	class USR_RPT_BRNCH_DC adj_pos_dc payperiod;
	var adjDirectRepairProgram 
		adjMaterialDamageAdjuster	
		adjEstimateDeskReview	
		adjSalvage	
		adjIndependentAdjuster	
		adjPhotoAppraisal
		adjOpenShop;
	wgt total_regular_hours_paid;
	output out= br_adjs (drop = _freq_ _type_) mean=;
	where adj_pos_dc ne 'Catastrophe Material Damage Adjuster';
run;

/* cat is blank since we have no hours to weight with */
/* roll up to region using hours as weight */
proc means data= ind_report3 noprint nway missing;
	class region adj_pos_dc payperiod;
	var adjDirectRepairProgram 
		adjMaterialDamageAdjuster	
		adjEstimateDeskReview	
		adjSalvage	
		adjIndependentAdjuster	
		adjPhotoAppraisal
		adjOpenShop;
	wgt total_regular_hours_paid;
	output out= regn_adjs (drop = _freq_ _type_) mean=;
	where adj_pos_dc ne 'Catastrophe Material Damage Adjuster';
run;

/* create the mega-file for qlik */
data qlik;
	set ind_report;
	length qlikapptyp $3.;

	if SEL_APPR_TYP_DC = 'DriveIn' then
		delete;
	else if SEL_APPR_TYP_DC= 'DirectRepairProgram' then
		qlikapptyp = 'DRP';
	else if SEL_APPR_TYP_DC= 'EstimateDeskReview' then
		qlikapptyp = 'EDR';
	else if SEL_APPR_TYP_DC= 'IndependentAdjuster' then
		qlikapptyp = 'IA';
	else if SEL_APPR_TYP_DC= 'MaterialDamageAdjuster' then
		qlikapptyp = 'MDA';
	else if SEL_APPR_TYP_DC= 'OpenShop' then
		qlikapptyp = 'OS';
	else if SEL_APPR_TYP_DC= 'PhotoAppraisal' then
		qlikapptyp = 'PA';
	else if SEL_APPR_TYP_DC= 'Salvage' then
		qlikapptyp = 'SAL';
run;

/* transpose individual table */
proc sort data= qlik;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
run;

/* 1- adjustment */
proc transpose data=qlik out=qlik1 prefix=final_adj_cap_;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var norm_adj;
run;

/* 2- vehicle */
proc transpose data=qlik out=qlik2 prefix=vehicle_r_;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var vehicle_r;
run;

/* 3- service area */
proc transpose data=qlik out=qlik3 prefix=service_area_r_;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var service_area_r;
run;

/* 4- incident */
proc transpose data=qlik out=qlik4 prefix=incident_r_;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var incident_r;
run;

/* 5- appraisal */
proc transpose data=qlik out=qlik5 prefix=appraisal_r_;
	by EMP_ID payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var appraisal_r;
run;

PROC SQL;
	CREATE TABLE qlik_ind As
		Select 	a.EMP_ID
			,a.payperiod
			,a.USR_RPT_BRNCH_DC
			,a.adj_pos_dc
			,a.region

			,a.final_adj_cap_DRP
			,a.final_adj_cap_EDR
			,a.final_adj_cap_IA
			,a.final_adj_cap_MDA
			,a.final_adj_cap_OS
			,a.final_adj_cap_PA
			,a.final_adj_cap_SAL
			, 1 as final_adj_cap_DV /* new */

	,qlik2.vehicle_r_DRP
	,qlik2.vehicle_r_EDR
	,qlik2.vehicle_r_IA
	,qlik2.vehicle_r_MDA
	,qlik2.vehicle_r_OS
	,qlik2.vehicle_r_PA
	,qlik2.vehicle_r_SAL
	, . as vehicle_r_DV /*new */

	,qlik3.service_area_r_DRP
	,qlik3.service_area_r_EDR
	,qlik3.service_area_r_IA
	,qlik3.service_area_r_MDA
	,qlik3.service_area_r_OS
	,qlik3.service_area_r_PA
	,qlik3.service_area_r_SAL
	, . as service_area_r_DV /*new */

	,qlik4.incident_r_DRP
	,qlik4.incident_r_EDR
	,qlik4.incident_r_IA
	,qlik4.incident_r_MDA
	,qlik4.incident_r_OS
	,qlik4.incident_r_PA
	,qlik4.incident_r_SAL
	, . as incident_r_DV /*new */

	,qlik5.appraisal_r_DRP
	,qlik5.appraisal_r_EDR
	,qlik5.appraisal_r_IA
	,qlik5.appraisal_r_MDA
	,qlik5.appraisal_r_OS
	,qlik5.appraisal_r_PA
	,qlik5.appraisal_r_SAL
	, . as appraisal_r_DV /*new */
	From qlik1 as A 

	left join qlik2
		on A.EMP_ID = qlik2.EMP_ID
		and A.payperiod = qlik2.payperiod
		and A.USR_RPT_BRNCH_DC = qlik2.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik2.adj_pos_dc

	left join qlik3
		on A.EMP_ID = qlik3.EMP_ID
		and A.payperiod = qlik3.payperiod
		and A.USR_RPT_BRNCH_DC = qlik3.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik3.adj_pos_dc

	left join qlik4 
		on A.EMP_ID = qlik4.EMP_ID
		and A.payperiod = qlik4.payperiod
		and A.USR_RPT_BRNCH_DC = qlik4.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik4.adj_pos_dc

	left join qlik5
		on A.EMP_ID = qlik5.EMP_ID
		and A.payperiod = qlik5.payperiod
		and A.USR_RPT_BRNCH_DC = qlik5.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik5.adj_pos_dc
	;
QUIT;

data qlik_ind;
	set qlik_ind;

	if adj_pos_dc = 'Material Damage Adjuster' then
		adj_pos_dc = 'Field Adjuster';
run;

/* merge branch stuff */
PROC SQL;
	CREATE TABLE qlik_all As
		Select A.*
			, B.adjDirectRepairProgram as DRP_adj_br
			, b.adjMaterialDamageAdjuster as MDA_adj_br
			, b.adjEstimateDeskReview as EDR_adj_br
			, b.adjSalvage as SAL_adj_br
			, b.adjIndependentAdjuster as IA_adj_br	
			, b.adjPhotoAppraisal as PA_adj_br
			, 1 as DV_adj_br /*new */
	From qlik_ind as A left join br_adjs as B
		on A.USR_RPT_BRNCH_DC = B.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = B.adj_pos_dc
		and a.payperiod = b.payperiod
	;
QUIT;

/* merge region stuff */
PROC SQL;
	CREATE TABLE qlik_all As
		Select A.*
			, B.adjDirectRepairProgram as DRP_adj_rgn
			, b.adjMaterialDamageAdjuster as MDA_adj_rgn
			, b.adjEstimateDeskReview as EDR_adj_rgn
			, b.adjSalvage as SAL_adj_rgn
			, b.adjIndependentAdjuster as IA_adj_rgn	
			, b.adjPhotoAppraisal as PA_adj_rgn
			, 1 as DV_adj_rgn /*new */
	From qlik_all as A left join regn_adjs as B
		on A.region = B.region
		and A.adj_pos_dc = B.adj_pos_dc
		and a.payperiod = b.payperiod
	;
QUIT;

data qlik_all;
	set qlik_all;

	/* make matchin position descriptions for hours merge */
	if adj_pos_dc = 'Material Damage Adjuster' then
		adj_pos_dc = 'Field Adjuster';
run;

/* merge to hours / counts data */
PROC SQL;
	CREATE TABLE qlik_final As
		Select
			A.REGION,
			A.RPT_ENTITY,
			A.JOB_TTL,
			A.USR_NTRL_ID,
			A.EMP_NM,
			A.EMP_ID,
			A.SPVS_NM,
			A.SPVS_EMP_ID,
			A.PayperiodEnd,
			A.year,
			A.month,
			A.EmpIDPPE,
			A.PayperiodEnd_dt,
			A.EmpIDPPE_dt,
			A.DISCIPLINE,
			A.DISC_SEC,
			A.WRK_CLASS,
			A.LEADER_NM,
			A.LEADER_EMP_ID,
			A.PRIM_ROL_NM,
			A.MDA_Services_Complete,
			A.Direct_Repair_Program,
			A.Estimate_Desk_Review,
			A.Independent_Adjuster,
			A.Open_Shop,
			A.Photo_Appraisal,
			A.Salvage,
			A.DimVal,
			A.TotalRegHrsPaid,
			A.TotalOTHrsPaid,
			A.TotalPTOHrsPaid,
			B.final_adj_cap_MDA,
			B.final_adj_cap_DRP,
			B.final_adj_cap_EDR,
			B.final_adj_cap_IA,
			B.final_adj_cap_OS,
			B.final_adj_cap_PA,
			B.final_adj_cap_SAL,
			B.final_adj_cap_DV,
			B.vehicle_r_MDA,
			B.vehicle_r_DRP,
			B.vehicle_r_EDR,
			B.vehicle_r_IA,
			B.vehicle_r_OS,
			B.vehicle_r_PA,
			B.vehicle_r_SAL,
			B.vehicle_r_DV,
			B.service_area_r_MDA,
			B.service_area_r_MDA,
			B.service_area_r_DRP,
			B.service_area_r_EDR,
			B.service_area_r_IA,
			B.service_area_r_OS,
			B.service_area_r_PA,
			B.service_area_r_SAL,
			B.service_area_r_DV,
			B.incident_r_MDA,
			B.incident_r_MDA,
			B.incident_r_DRP,
			B.incident_r_EDR,
			B.incident_r_IA,
			B.incident_r_OS,
			B.incident_r_PA,
			B.incident_r_SAL,
			B.incident_r_DV,
			B.appraisal_r_MDA,
			B.appraisal_r_MDA,
			B.appraisal_r_DRP,
			B.appraisal_r_EDR,
			B.appraisal_r_IA,
			B.appraisal_r_OS,
			B.appraisal_r_PA,
			B.appraisal_r_SAL,
			B.appraisal_r_DV,
			B.MDA_adj_br,
			B.DRP_adj_br,
			B.EDR_adj_br,
			B.IA_adj_br,
			1 as OS_adj_br,
			B.PA_adj_br,
			B.SAL_adj_br,
			B.DV_adj_br,
			B.MDA_adj_rgn,
			B.DRP_adj_rgn,
			B.EDR_adj_rgn,
			B.IA_adj_rgn,
			1 as OS_adj_rgn,
			B.PA_adj_rgn,
			B.SAL_adj_rgn,
			B.DV_adj_rgn
		From mdl_curr.hcoutput as A left join qlik_all as B
			on B.EMP_ID = A.EMP_ID
			and B.adj_pos_dc = A.JOB_TTL
			and B.USR_RPT_BRNCH_DC = A.RPT_ENTITY
			and B.payperiod = A.PayperiodEnd_dt
	;
QUIT;

proc sql;
	create table duplicates as 
		select *
			from qlik_final
				group by EMP_ID, PayperiodEnd_dt
					having count(*) gt 1;
quit;

/* fill in 1.0s */
data qlik_final (drop=i);
	set qlik_final;

	/* file in 1.00 for missing factors */
	array N[*] final_adj_cap_MDA --  SAL_adj_rgn;

	do i=1 to hbound(N);
		if N[i]=. then
			N[i]=1;
	end;
run;

data qlik_final;
	set qlik_final;
	keep REGION RPT_ENTITY JOB_TTL USR_NTRL_ID EMP_NM EMP_ID SPVS_NM SPVS_EMP_ID
		PayperiodEnd year month EmpIDPPE PayperiodEnd_dt EmpIDPPE_dt
		DISCIPLINE DISC_SEC WRK_CLASS LEADER_NM LEADER_EMP_ID PRIM_ROL_NM
		MDA_Services_Complete Direct_Repair_Program Estimate_Desk_Review
		Independent_Adjuster Open_Shop Photo_Appraisal Salvage DimVal
		TotalRegHrsPaid TotalOTHrsPaid TotalPTOHrsPaid
		final_adj_cap_MDA final_adj_cap_DRP final_adj_cap_EDR final_adj_cap_IA
		final_adj_cap_OS final_adj_cap_PA final_adj_cap_SAL final_adj_cap_DV
		vehicle_r_MDA vehicle_r_DRP vehicle_r_EDR vehicle_r_IA vehicle_r_OS
		vehicle_r_PA vehicle_r_SAL vehicle_r_DV
		service_area_r_MDA service_area_r_DRP service_area_r_EDR service_area_r_IA service_area_r_OS
		service_area_r_PA service_area_r_SAL service_area_r_DV
		incident_r_MDA incident_r_DRP incident_r_EDR incident_r_IA incident_r_OS incident_r_PA
		incident_r_SAL incident_r_DV
		appraisal_r_MDA appraisal_r_DRP appraisal_r_EDR appraisal_r_IA appraisal_r_OS appraisal_r_PA
		appraisal_r_SAL appraisal_r_DV
		MDA_adj_br DRP_adj_br EDR_adj_br IA_adj_br OS_adj_br PA_adj_br SAL_adj_br DV_adj_br
		MDA_adj_rgn DRP_adj_rgn EDR_adj_rgn IA_adj_rgn OS_adj_rgn PA_adj_rgn SAL_adj_rgn DV_adj_rgn;
run;

/* transpose completed services file */
PROC SQL;
	CREATE TABLE qa_completed As
		Select b.EMP_ID
			,b.JOB_TTL
			,b.RPT_ENTITY
			,b.PayperiodEnd_dt
			,b.Direct_Repair_Program as DirectRepairProgram
			,b.MDA_Services_Complete as MaterialDamageAdjuster
			,b.Estimate_Desk_Review as EstimateDeskReview
			,b.Salvage
			,b.Open_Shop as OpenShop
			,b.Independent_Adjuster as IndependentAdjuster
			,b.Photo_Appraisal as PhotoAppraisal
			,b.DimVal
		From mdl_curr.hcoutput as b
	;
QUIT;

proc sort data= qa_completed;
	by EMP_ID RPT_ENTITY PayperiodEnd_dt JOB_TTL;
run;

/* transpose wide to long */
proc transpose data=qa_completed out=qa_completed_w /*prefix=adj*/;
	by EMP_ID RPT_ENTITY PayperiodEnd_dt JOB_TTL;

	/*	    id SEL_APPR_TYP_DC;*/
	var DirectRepairProgram -- DimVal;
run;

data ind_report2;
	set ind_report;

	if adj_pos_dc = 'Material Damage Adjuster' then
		adj_pos_dc = 'Field Adjuster';
run;

/* merge */
PROC SQL;
	CREATE TABLE qlik_adj1 As
		Select b._NAME_ as SEL_APPR_TYP_DC
			,b.EMP_ID
			,a.region as REGION
			,b.RPT_ENTITY
			,b.JOB_TTL
			,b.PayperiodEnd_dt as PayPeriodEnd_dt
			,cat(b.EMP_ID,year(b.PayperiodEnd_dt),put(month(b.PayperiodEnd_dt),z2.),put(day(b.PayperiodEnd_dt),z2.)) as EmpIDPPE_dt
			,b.col1 as Closed_Svc
			,coalesce(a.norm_adj,1) as norm_adj
			,a.vehicle_r
			,a.service_area_r
			,a.incident_r
			,a.appraisal_r
		From qa_completed_w as b
			left join ind_report2 as a
				on A.SEL_APPR_TYP_DC = b._NAME_
				and b.EMP_ID = a.EMP_ID
				and B.RPT_ENTITY = a.USR_RPT_BRNCH_DC
				and B.JOB_TTL = a.ADJ_POS_DC
				and B.PayperiodEnd_dt = a.PayPeriod
	;
QUIT;

data qlik_adj1;
	set qlik_adj1;
	where not missing(Closed_Svc);
run;

data qlik_adj1;
	set qlik_adj1;
	keep SEL_APPR_TYP_DC EMP_ID REGION RPT_ENTITY JOB_TTL PayPeriodEnd_dt
		EmpIDPPE_dt Closed_Svc norm_adj vehicle_r service_area_r incident_r appraisal_r;
run;

/* excel output */
%macro ExportCustom();
	%if &flag. = 1 %then
		%do;

			proc export data=qlik_final 
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/MaterialDamage-QlikSuperfile.xlsx"
				dbms=xlsx
				replace;
			run;

			/* excel output */
			proc export data=qlik_adj1 
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/MaterialDamage-QlikAdjustments.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
	%else
		%do;

			proc export data=qlik_final 
				outfile="&output_path_csv/MaterialDamage-QlikSuperfile.xlsx"
				dbms=xlsx
				replace;
			run;

			/* excel output */
			proc export data=qlik_adj1 
				outfile="&output_path_csv/MaterialDamage-QlikAdjustments.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
%mend ExportCustom;

%ExportCustom();