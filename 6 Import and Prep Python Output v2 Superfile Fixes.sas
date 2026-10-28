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
			, B.'Adj Number'n
		From for_report as A left join mdl_curr.adj_decode as B
			on compress(A.ADJ_NM) = b.adjnm
	;
QUIT;

/* take individual means early */
proc means data= for_report noprint nway missing;
	class SEL_APPR_TYP_DC 'Adj Number'n ADJ_POS_DC USR_RPT_BRNCH_DC payperiod;
	var model_elaps vehicle service_area incident appraisal;
	output out= adj_mdl (drop = _type_ ) mean=;
	where not missing('Adj Number'n);
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
			, a.'Adj Number'n
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
	keep 'Adj Number'n	
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
	by 'Adj Number'n region USR_RPT_BRNCH_DC payperiod adj_pos_dc;
run;

proc transpose data=ind_report out=ind_report2 prefix=adj;
	by 'Adj Number'n region USR_RPT_BRNCH_DC payperiod adj_pos_dc;
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
			,b.'Direct Repair Program'n 
			,b.'mda services complete'n as Material_Damage_Adjuster	
			,b.'Estimate Desk Review'n as Estimate_Desk_Review	
			,b.Salvage  	
			,b.'Independent Adjuster'n as Independent_Adjuster	
			,b.'Photo Appraisal'n as Photo_Appraisal
			,b.DimVal															

	, B.'total regular hours paid'n as total_regular_hours_paid 
	From ind_report2 as A left join mdl_curr.hcoutput as B
		on A.'Adj Number'n = B.'Adj Number'n
		/*and a.adj_pos_dc = b.'Adj Position'n*/
        /*and A.USR_RPT_BRNCH_DC = B.'Adjuster Team Branch'n*/
	and A.payperiod = B.payperioddate
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
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
run;

/* 1- adjustment */
proc transpose data=qlik out=qlik1 prefix=final_adj_cap_;
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var norm_adj;
run;

/* 2- vehicle */
proc transpose data=qlik out=qlik2 prefix=vehicle_r_;
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var vehicle_r;
run;

/* 3- service area */
proc transpose data=qlik out=qlik3 prefix=service_area_r_;
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var service_area_r;
run;

/* 4- incident */
proc transpose data=qlik out=qlik4 prefix=incident_r_;
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var incident_r;
run;

/* 5- appraisal */
proc transpose data=qlik out=qlik5 prefix=appraisal_r_;
	by 'Adj Number'n payperiod region USR_RPT_BRNCH_DC adj_pos_dc;
	id qlikapptyp;
	var appraisal_r;
run;

PROC SQL;
	CREATE TABLE qlik_ind As
		Select 	a.'Adj Number'n
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
		on A.'Adj Number'n = qlik2.'Adj Number'n
		and A.payperiod = qlik2.payperiod
		and A.USR_RPT_BRNCH_DC = qlik2.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik2.adj_pos_dc

	left join qlik3
		on A.'Adj Number'n = qlik3.'Adj Number'n
		and A.payperiod = qlik3.payperiod
		and A.USR_RPT_BRNCH_DC = qlik3.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik3.adj_pos_dc

	left join qlik4 
		on A.'Adj Number'n = qlik4.'Adj Number'n
		and A.payperiod = qlik4.payperiod
		and A.USR_RPT_BRNCH_DC = qlik4.USR_RPT_BRNCH_DC
		and A.adj_pos_dc = qlik4.adj_pos_dc

	left join qlik5
		on A.'Adj Number'n = qlik5.'Adj Number'n
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
			"Material Damage" as SpecialtyGroup /* new */

	,A.'Adjuster Region'n
	,a.'Adjuster Team Branch'n
	,a.'Adj Position'n
	,a.'Adj Nm'n
	,a.'Adj Number'n
	,a.'SupvNam'n
	,a.'Supv#'n
	,a.payperioddate
	,Year(a.payperioddate) as year
	,Month(a.payperioddate) as month
	,cat(a.'Adj Number'n,year(a.PayPeriodDate),put(month(a.PayPeriodDate),z2.),put(day(a.PayPeriodDate),z2.)) as EmpID_PP 						/* new */

	/*	counts*/

	,a.'MDA Services Complete'n
	,a.'Direct Repair Program'n
	,a.'Estimate Desk Review'n
	,a.'Independent Adjuster'n
	,a.'Open Shop'n
	,a.'Photo Appraisal'n
	,a.Salvage
	,a.DimVal /*new */

	/*hours*/

	,a.'Total Regular Hours Paid'n
	,a.'Total Overtime Hours Paid'n

	/* ind target by type */

	,b.final_adj_cap_MDA
	,b.final_adj_cap_DRP
	,b.final_adj_cap_EDR
	,b.final_adj_cap_IA
	,b.final_adj_cap_OS
	,b.final_adj_cap_PA
	,b.final_adj_cap_SAL
	, 1 as final_adj_cap_DV /*new */

	/* ind rank by type */

	,b.vehicle_r_MDA
	,b.vehicle_r_DRP
	,b.vehicle_r_EDR
	,b.vehicle_r_IA
	,b.vehicle_r_OS
	,b.vehicle_r_PA
	,b.vehicle_r_SAL
	, 1 as vehicle_r_DV /*new */

	/* ind rank by type */

	,b.service_area_r_MDA
	,b.service_area_r_DRP
	,b.service_area_r_EDR
	,b.service_area_r_IA
	,b.service_area_r_OS
	,b.service_area_r_PA
	,b.service_area_r_SAL
	, 1 as service_area_r_DV /*new */

	/* ind rank by type */

	,b.incident_r_MDA
	,b.incident_r_DRP
	,b.incident_r_EDR
	,b.incident_r_IA
	,b.incident_r_OS
	,b.incident_r_PA
	,b.incident_r_SAL
	, 1 as incident_r_DV /*new */

	/* ind rank by type */

	,b.appraisal_r_MDA
	,b.appraisal_r_DRP
	,b.appraisal_r_EDR
	,b.appraisal_r_IA
	,b.appraisal_r_OS
	,b.appraisal_r_PA
	,b.appraisal_r_SAL
	, 1 as appraisal_r_DV /*new */

	/* branch adjustments */

	, b.MDA_adj_br
	, B.DRP_adj_br
	, b.EDR_adj_br
	, b.IA_adj_br
	, 1 as OS_adj_br
	, b.PA_adj_br
	, b.SAL_adj_br
	, 1 as DV_adj_br /*new */

	/* region adjustments */

	, b.MDA_adj_rgn
	, B.DRP_adj_rgn
	, b.EDR_adj_rgn
	, b.IA_adj_rgn
	, 1 as OS_adj_rgn
	, b.PA_adj_rgn
	, b.SAL_adj_rgn
	, 1 as DV_adj_rgn /*new */
	From mdl_curr.hcoutput as A left join qlik_all as B
		on b.'Adj Number'n = a.'Adj Number'n
		and b.adj_pos_dc = a.'Adj Position'n
		and b.USR_RPT_BRNCH_DC = a.'Adjuster Team Branch'n
		and b.payperiod = a.payperioddate
	;
QUIT;

proc sql;
	create table duplicates as 
		select *
			from qlik_final
				group by 'Adj Number'n, payperioddate
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

/* transpose completed services file */
PROC SQL;
	CREATE TABLE qa_completed As
		Select b.'Adj Number'n
			,b.'Adj Position'n
			,B.'Adjuster Team Branch'n
			,B.payperioddate
			, b.'Direct Repair Program'n as DirectRepairProgram
			,b.'mda services complete'n as MaterialDamageAdjuster	
			,b.'Estimate Desk Review'n as EstimateDeskReview	
			,b.Salvage  
			,b.'Open Shop'n as OpenShop	
			,b.'Independent Adjuster'n as IndependentAdjuster	
			,b.'Photo Appraisal'n as PhotoAppraisal
			,b.DimVal /*new */
	From mdl_curr.hcoutput as b
	;
QUIT;

proc sort data= qa_completed;
	by 'Adj Number'n 'Adjuster Team Branch'n payperioddate 'Adj Position'n;
run;

/* transpose wide to long */
proc transpose data=qa_completed out=qa_completed_w /*prefix=adj*/;
	by 'Adj Number'n 'Adjuster Team Branch'n payperioddate 'Adj Position'n;

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
			,b.'Adj Number'n
			,a.region as Adjuster_Region
			,b.'Adjuster Team Branch'n
			,b.'Adj Position'n
			,b.payperioddate as payperiod
			,cat(b.'Adj Number'n,year(b.PayPeriodDate),put(month(b.PayPeriodDate),z2.),put(day(b.PayPeriodDate),z2.)) as EmpID_PP  /*MB will fill */

	,b.col1 as Closed_Svc
	,coalesce(a.norm_adj,1) as norm_adj
	,a.vehicle_r
	,a.service_area_r
	,a.incident_r
	,a.appraisal_r
	From qa_completed_w as b
		left join ind_report2 as a
			on 		A.SEL_APPR_TYP_DC = b._NAME_
			and b.'Adj Number'n = a.'Adj Number'n
			and	B.'Adjuster Team Branch'n = a.USR_RPT_BRNCH_DC
			and b.'Adj Position'n = a.ADJ_POS_DC
			and B.payperioddate =	a.PayPeriod
	;
QUIT;

data qlik_adj1;
	set qlik_adj1;
	where not missing(Closed_Svc);
run;

/* excel output */
%macro ExportCustom();
	%if &flag. = 1 %then
		%do;

			proc export data=qlik_final 
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/QlikSuperfile_md.xlsx"
				dbms=xlsx
				replace;
			run;

			/* excel output */
			proc export data=qlik_adj1 
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/QlikAdjustments SAS_md.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
	%else
		%do;

			proc export data=qlik_final 
				outfile="&output_path_csv/QlikSuperfile_md.xlsx"
				dbms=xlsx
				replace;
			run;

			/* excel output */
			proc export data=qlik_adj1 
				outfile="&output_path_csv/QlikAdjustments SAS_md.xlsx"
				dbms=xlsx
				replace;
			run;

		%end;
%mend ExportCustom;

%ExportCustom();