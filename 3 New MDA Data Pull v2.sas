/* Material Damage SAS Script 3 : 3 New MDA Data Pull v2*/
/* CCDS*/
LIBNAME CCDS ORACLE PATH=CDEP1 SCHEMA=BRFADM Authdomain=Oracle_Auth_CCDS;

proc sql;
	connect using ccds;
	create table MDA_SVC as
		select * from connection to ccds
			(
		select distinct
			CLM.CLM_NR
			, CLM.LOB_DC
			, clm.clm_ntrl_id

			, SVC_REQ.SEL_APPR_TYP_DC
			, SVC_REQ.CRT_DT AS SVC_CRT_DT
			, SVC_REQ.SVC_REQ_NR 
			, SVC_REQ.ASGN_USR_ID
			, SVC_REQ.LST_upd_DT
			, SVC_REQ.SEL_INSP_TYP_DC
			, SVC_REQ.SVC_REQ_TYP_DC
			, SVC_REQ.SLVG_ASGN_ACPT_IN

			, srhm.adj_nm
			, srhm.USR_RPT_BRNCH_DC
			, srhm.ADJ_POS_DC

			, SVCREQ_WRKLD_HIST.EVNT_DT
			, SVCREQ_WRKLD_HIST.SVC_REQ_PRGRS_TYP_DC  
			, SVCREQ_WRKLD_HIST.SVC_REQ_NTRL_ID
			, SVCREQ_WRKLD_HIST.WRKLD_HIST_TYP_DC
			, SVCREQ_WRKLD_HIST.EXPSR_NTRL_ID 

			, veh.MFR_YR
			, veh.MAKE_NM

			, INCID.INCID_NTRL_ID
			, incid.DRVR_INSD_REL_TYP_DC
			, incid.LIEN_LEAS_DC
			, incid.VEH_OPR_IN
			, incid.VEH_STYL_DC
			, incid.VEH_USE_RSN_DC
			, incid.COL_PNT_TYP_cd
			, ENTPR_CD_VW.cd_lbl as COL_PNT_TYP_DC2

			/* vehicle inspection */
			, ad.pstl_cd
			, AD.AD_NTRL_ID		/* to get language line */

			/* salvage */
			, spclsvc.SVC_TYP_DC

		from
			BRFADM.CLM
		LEFT JOIN BRFADM.INCID 
			ON CLM.CLM_NTRL_ID = INCID.CLM_NTRL_ID 
			AND INCID.REC_RET_IN = 'N' AND INCID.CRNT_REC_IN = 'Y'

		LEFT JOIN BRFADM.SVC_REQ 
			ON INCID.INCID_NTRL_ID = SVC_REQ.INCID_NTRL_ID 
			AND SVC_REQ.REC_RET_IN = 'N' AND SVC_REQ.CRNT_REC_IN = 'Y'
			AND SVC_REQ.CRT_DT BETWEEN to_date(&from_dt,'DDMONYYYY:HH24:MI:SS') AND to_date(&to_dt,'DDMONYYYY:HH24:MI:SS')

		left join BRFADM.SVC_REQ_HRCHY_MV srhm 
			on svc_req.SVC_REQ_NTRL_ID = srhm.SVC_REQ_NTRL_ID 
			and svc_req.lst_upd_dt between srhm.SVC_STRT_DT and srhm.SVC_END_DT

		left join BRFADM.WRKLD_HIST SVCREQ_WRKLD_HIST 
			on svc_req.SVC_REQ_NTRL_ID = SVCREQ_WRKLD_HIST.SVC_REQ_NTRL_ID 
			and svc_req.ASGN_USR_ID = SVCREQ_WRKLD_HIST.ASGN_USR_ID 

		left join BRFADM.VEH veh 
			on veh.VEH_NTRL_ID = incid.VEH_NTRL_ID 
			And veh.rec_ret_in = 'N' and veh.crnt_rec_in= 'Y'

			/* inspection address */
		left join BRFADM.ad 
			on INCID.INSP_LOC_ID = AD.AD_NTRL_ID 
			and ad.crnt_rec_in = 'Y' and ad.rec_ret_in = 'N'

			/* salvage */
		left join BRFADM.SVC_REQ_INSTR svcinstr 
			on svcinstr.SVC_REQ_NTRL_ID = SVC_REQ.SVC_REQ_NTRL_ID 
			and svcinstr.CRNT_REC_IN = 'Y' 
		left join BRFADM.SVC_REQ_INSTR_SVC svcinstrsvc 
			on svcinstrsvc.SVC_REQ_INSTR_NTRL_ID = svcinstr.SVC_REQ_INSTR_NTRL_ID 
			and svcinstrsvc.CRNT_REC_IN = 'Y' 
		left join BRFADM.SPCL_SVC spclsvc 
			on spclsvc.SPCL_SVC_NTRL_ID=svcinstrsvc.SPCL_SVC_NTRL_ID 
			and spclsvc.crnt_rec_in= 'Y'

			/* fixed collision point */
		left join BRFADM.ENTPR_CD_VW ENTPR_CD_VW 
			on ENTPR_CD_VW.entpr_cd_id = incid.COL_PNT_TYP_cd
			and ENTPR_CD_VW.CD_SCHM_ID = 668

		where
			SVCREQ_WRKLD_HIST.SVC_REQ_PRGRS_TYP_DC = 'WorkComplete' 
			and SVCREQ_WRKLD_HIST.WRKLD_HIST_TYP_DC = 'Closed'  

			);
	disconnect from ccds
	;
quit;

/* make salvage a service */
data mda_svc (drop=SVC_TYP_DC);
	set mda_svc;

	if missing(SVC_TYP_DC) and missing(SEL_APPR_TYP_DC) then
		delete;
	else if missing(SEL_APPR_TYP_DC) then
		SEL_APPR_TYP_DC = SVC_TYP_DC;
run;

/* filter for the services we want to include */
data mda_svc;
	set mda_svc;
	where SEL_APPR_TYP_DC in 
		('MaterialDamageAdjuster',
		'DirectRepairProgram',
		'IndependentAdjuster',
		'EstimateDeskReview',
		'OpenShop',
		'PhotoAppraisal',
		'Salvage');

	/* at 6/24 meeting they said these are the same for assignment type */
	if ADJ_POS_DC in ('Material Damage Adj (Trainee)','Material Damage Adj I','Material Damage Adj II',
		'Material Damage Adjsuter II','Material Damage Adjuser I','Material Damage Adjuster',
		'Material Damage Adjuster I','Material Damage Adjuster II','Material Damage Adjutster II') then
		ADJ_POS_DC = 'Material Damage Adjuster';
	else if ADJ_POS_DC in ('Material Damage Inside Adj I','Material Damage Inside Adjuster I','Material Damage Inside Adjuster')
		then
		ADJ_POS_DC = 'Material Damage Inside Adjuster I';
	else if ADJ_POS_DC in ('Material Damage Inside  Adjuster II','Material Damage Inside Adj II'
		'Material Damage Inside Adjsuter II','Material Damage Inside Adjuster II')
		then
		ADJ_POS_DC = 'Material Damage Inside Adjuster II';

	/* we did unique names in iniital pull, but sometimes names have asterisk if RMV */
	ADJ_NM = compress(strip(tranwrd(ADJ_NM,"T*","")));

	/* no assigned name/adjuster yet */
	if index(ADJ_NM,"Pending")>0 then
		delete;

	/* odd one-offs 3.6.2025 */
	if ADJ_NM = 'Wynder,Cherrish' then
		ADJ_NM = 'Clayton,Cherrish';

	if ADJ_NM = 'Moffitt,David' then
		ADJ_NM = 'Moffitt,Brandon';

	/* rare duplicate source */
	if substr(clm_nr,1,1) = 'Z' then
		delete;
run;

/* re-do distinct pull */
PROC SQL;
	CREATE TABLE mda_svc As
		Select Distinct *
			From mda_svc as A
	;
QUIT;

/* check for success - should be 0 records */
proc sql;
	create table duplicates as 
		select *
			from mda_svc as a
				group by a.SVC_REQ_NR
					having count(*) gt 1;
quit;

/* new fields */
/*Supplements*/
proc sql;
	connect using CCDS;
	create table supplements as
		select * from connection to ccds
		(SELECT DISTINCT

			clm.clm_nr 
			, clm.loss_dt
			, clm.crt_dt
			, incid.incid_ntrl_id
			, assmt_src.assmt_src_nm

		FROM

			brfadm.CLM

		left join brfadm.INCID on 
			clm.clm_ntrl_id = incid.clm_ntrl_id and incid.crnt_rec_in = 'Y' and incid.rec_ret_in = 'N'

		inner join brfadm.ASSMT_SRC on 
			incid.incid_ntrl_id = assmt_src.incid_ntrl_id and assmt_src.crnt_rec_in = 'Y' and assmt_src.rec_ret_in = 'N'
			and assmt_src.assmt_src_nm like ('Supplemental%')

		where clm.crnt_rec_in = 'Y' and clm.rec_ret_in = 'N' 
			and assmt_src.assmt_src_nm like ('Supplemental%')

			);
	disconnect from ccds;
quit;

/* turn into a count by incident number */
proc sql;
	create table supp_counts as 
		select incid_ntrl_id,
			count(assmt_src_nm) as supplements 
		from supplements
			group by incid_ntrl_id
	;
quit;

/* merge it on */
PROC SQL;
	CREATE TABLE MDA_SVC As
		Select A.*
			, coalesce(B.supplements,0) as supplements
			, min(coalesce(B.supplements,0),5) as supplements_cap5
		From MDA_SVC as A left join supp_counts as B
			on A.incid_ntrl_id = B.incid_ntrl_id
	;
QUIT;

/*Rental is a service 																						   	 */
proc sql;
	connect using CCDS;
	create table rentals as
		select * from connection to ccds
			(
		select distinct
			clm.clm_nr  
			, clm.clm_ntrl_id
			, SPCL_SVC.svc_nm_txt
			, 
		case 
			-					
			when svc_req.sel_appr_typ_dc is null then SPCL_SVC.svc_nm_txt  
			else svc_req.sel_appr_typ_dc 
		end 
	as Svcs_AsgnTyp  
		, incid.INCID_NTRL_ID
		,expsr.expsr_ntrl_id /* new one for merge */
	FROM brfadm.svc_req 
		Left Join brfadm.clm  
			ON CLM.CLM_NTRL_ID = svc_req.CLM_NTRL_ID
			AND clm.rec_ret_in = 'N' AND clm.crnt_rec_in = 'Y'
			/* new one for merge */
		LEFT JOIN 	brfadm.expsr  
			on clm.clm_ntrl_id = expsr.clm_ntrl_id 
			and clm.clmt_id = expsr.clmt_id /* trying to fix dupes - this from data dictionary */
			and expsr.crnt_rec_in = 'Y' and expsr.rec_ret_in = 'N'
		Left Join brfadm.INCID  
			ON CLM.CLM_NTRL_ID = INCID.CLM_NTRL_ID
			AND INCID.rec_ret_in = 'N' AND INCID.crnt_rec_in = 'Y'	and INCID.SBTYP_DC in ('VehicleIncident')
		Left Join brfadm.SVC_REQ_INSTR  SVC_REQ_INSTR
			on svc_req.SVC_REQ_NTRL_ID = SVC_REQ_INSTR.SVC_REQ_NTRL_ID	and SVC_REQ_INSTR.crnt_rec_in= 'Y'
		Left Join brfadm.SVC_REQ_INSTR_SVC  
			on SVC_REQ_INSTR.SVC_REQ_INSTR_NTRL_ID  = SVC_REQ_INSTR_SVC.SVC_REQ_INSTR_NTRL_ID 
			and SVC_REQ_INSTR_SVC.crnt_rec_in = 'Y'
		inner Join brfadm.SPCL_SVC  
			on SVC_REQ_INSTR_SVC.SPCL_SVC_NTRL_ID = SPCL_SVC.SPCL_SVC_NTRL_ID
			and SPCL_SVC.crnt_rec_in= 'Y' and SPCL_SVC.svc_nm_txt in ('Car rental')
		where svc_req.CRNT_REC_IN = 'Y' and svc_req.PRGRS_DC  NOT IN  ( 'Declined','Canceled'  )
			and svc_req.asgn_dt between to_date(&from_dt,'DDMONYYYY:HH24:MI:SS') AND to_date(&to_dt,'DDMONYYYY:HH24:MI:SS')  
			);
	disconnect from ccds
	;
quit;

PROC SQL;
	CREATE TABLE rentals2 as
		SELECT *
			FROM rentals as A
				WHERE A.INCID_NTRL_ID in (SELECT B.INCID_NTRL_ID from mda_svc as B);
QUIT;

proc sql;
	create table rentals_dupe as 
		select *
			from rentals
				group by INCID_NTRL_ID
					having count(*) gt 1;
quit;

PROC SQL;
	CREATE TABLE mda_svc As
		Select A.*
			, B.Svcs_AsgnTyp as rental
		From mda_svc as A left join rentals as B
			on A.INCID_NTRL_ID = B.INCID_NTRL_ID
	;
QUIT;

/* create indicator */
data mda_svc;
	set mda_svc;
	has_rental = 0;

	if not missing(rental) then
		has_rental = 1;
run;

/* end new features*/
/* start creating fields */
data mda_svc;
	set mda_svc;
	where ADJ_POS_DC in ('Material Damage Adjuster',
		'Material Damage Inside Adjuster II',
		'Material Damage Inside Adjuster I');
	format svc_crt_date mmddyy10.;
	svc_crt_date =datepart(SVC_CRT_DT);
	svc_crt_year = year(datepart(SVC_CRT_DT));
	svc_crt_month = month(datepart(SVC_CRT_DT));
run;

/* merge home zip codes of MDA adjusters */
/* separate program (program 2 creates) */
PROC SQL;
	CREATE TABLE mda_svc As
		Select A.*
			, substr(B.postal,1,5) as adjuster_postal
		From mda_svc as A left join src.zips as B
			on a.adj_nm = B.name2
	;
QUIT;

/* bring in vehicles within 20 miles of inspection zip code (made separately) */
PROC SQL;
	CREATE TABLE mda_svc As
		Select A.*
			, B.vehicles as vehicles_in_20mi
		From mda_svc as A left join src.countbyzip20 as B
			on A.pstl_cd = B.zip20
	;
QUIT;

/* if missing, use average */
data mda_svc;
	set mda_svc;

	if missing(vehicles_in_20mi) then
		vehicles_in_20mi = 70000;
run;

/* summarize counts by day */
proc sql;
	create table svc_presum as 
		select 
			ASGN_USR_ID, 
			SEL_APPR_TYP_DC,
			count(SVC_REQ_NR) as services,
			svc_crt_date
		from mda_svc
			group by ASGN_USR_ID, SEL_APPR_TYP_DC, svc_crt_date;
quit;

/* combine records by date and create rolling sum */
proc sql;
	create table rolling_count as
		select  ASGN_USR_ID,
			svc_crt_date,
			SEL_APPR_TYP_DC,
			services,
			sum(TMP) as services_roll7
		from    (
			select  A.*,
				B.services as TMP
			from    svc_presum A
				left join svc_presum B
					on      A.ASGN_USR_ID=B.ASGN_USR_ID
					and 	A.SEL_APPR_TYP_DC=B.SEL_APPR_TYP_DC
					and     A.svc_crt_date-7 <= B.svc_crt_date <= A.svc_crt_date
					)
				group by ASGN_USR_ID,
					svc_crt_date,
					SEL_APPR_TYP_DC,
					services
	;
quit;

/* transpose by service */
proc transpose data=rolling_count out=rolling_count2;
	by ASGN_USR_ID svc_crt_date;
	id SEL_APPR_TYP_DC;
	var services_roll7;
run;

/* fill in zeros */
data rolling_count2;
	set rolling_count2 (drop=_NAME_);
	total_7 = sum(MaterialDamageAdjuster,DirectRepairProgram,IndependentAdjuster,
		EstimateDeskReview,	OpenShop,PhotoAppraisal,Salvage);

	/* fill in missings with zeroes */
	array N[*] MaterialDamageAdjuster DirectRepairProgram IndependentAdjuster EstimateDeskReview 
		OpenShop PhotoAppraisal  Salvage;

	do i=1 to hbound(N);
		if N[i]=. then
			N[i]=0;
	end;
run;

/* merge on to dataset */
PROC SQL;
	CREATE TABLE mda_svc As
		Select A.*
			, B.MaterialDamageAdjuster 
			, B.DirectRepairProgram 
			, B.IndependentAdjuster 
			, B.EstimateDeskReview 
			, B.OpenShop 
			, B.PhotoAppraisal 
			, b.salvage
			, b.total_7
		From mda_svc as A left join rolling_count2 as B
			on A.ASGN_USR_ID = B.ASGN_USR_ID
			and a.svc_crt_date = B.svc_crt_date
	;
QUIT;

/* append drive time */
PROC SQL;
	CREATE TABLE temp As
		Select A.*
			, B.drive_distance 
			, round(b.drive_time,5) as drivetime
			, substr(A.pstl_cd,1,5) as zip5
		From mda_svc as A left join src.drivetimes as B
			on A.adjuster_postal = B.adj_zip
			and substr(A.pstl_cd,1,5) = B.zip5_x;
quit;

/* if inside adjuster or ia service, make this zero */
/* they dont travel */
data temp;
	set temp;

	/* zero our for non-mda services */
	if ADJ_POS_DC not in ('Material Damage Adjuster') or SEL_APPR_TYP_DC ne 'MaterialDamageAdjuster' then
		do;
			drive_distance = 0;
			drivetime = 0;
		end;

	/* drivetime file does not do matching zip codes */
	if missing(drive_distance) 
		and adjuster_postal = substr(pstl_cd,1,5) 
		and not missing(adjuster_postal) then
		do;
			drive_distance = 2;
			drivetime = 5;
		end;
run;

/* separate hit and nohit */
data good nogood (drop=drive_distance drivetime);
	set temp;

	if missing(drive_distance) then
		output nogood;
	else output good;
run;

/*if missing, use average for inspection zip*/
proc means data= good noprint nway missing;
	var drive_distance drivetime;
	class zip5;
	output out= zipavg (drop = _Freq_ _type_) mean=;
	where ADJ_POS_DC = ('Material Damage Adjuster') and SEL_APPR_TYP_DC = 'MaterialDamageAdjuster';
run;

PROC SQL;
	CREATE TABLE nogood As
		Select A.*
			, B.drive_distance 
			, round(b.drivetime,5) as drivetime
		From nogood as A left join zipavg as B
			on substr(A.pstl_cd,1,5) = B.zip5;
quit;

/* stack */
data mdata;
	set good nogood;

	/* set to overall average */
	if missing(drive_distance) then
		do;
			drive_distance = 25;
			drivetime = 40;
		end;
run;

/* calculate branch staffing level */
/* calculate employee counts */
PROC SQL;
	CREATE TABLE employees As
		Select  
			svc_crt_year 
			,svc_crt_month 
			,usr_rpt_brnch_dc 
			,ADJ_POS_DC
			,count (distinct ADJ_NM) as emp_count

		From mdata as A
			group by 
				svc_crt_year 
				,svc_crt_month 
				,usr_rpt_brnch_dc 
				,ADJ_POS_DC
	;
QUIT;

/* append employee count */
PROC SQL;
	CREATE TABLE mdata As
		Select A.*
			, min(B.emp_count,40) as br_pos_emp_count 
		From mdata as A left join employees as B
			on A.svc_crt_year = B.svc_crt_year
			and A.svc_crt_month = B.svc_crt_month
			and A.usr_rpt_brnch_dc = B.usr_rpt_brnch_dc
			and A.ADJ_POS_DC = B.ADJ_POS_DC
	;
QUIT;

data mdata;
	set mdata;
	length 	VEH_STYL_DC_grp $20.
		DRVR_INSD_REL_TYP_DC_grp $8.
		make_grp $9.
		LOB_grp $8.
		Veh_USE_RSN_DC_grp $10.
		coll_pnt_grp $12.;

	/* CREATE TARGET VARIABLE - elapsed time  */
	elaps = round(((EVNT_DT - SVC_CRT_DT)/86400),.001);

	/* adjust dates to remove weekends */
	days_full = datepart(EVNT_DT)-datepart(SVC_CRT_DT);
	days_nowknd = intck('WEEKDAY', datepart(SVC_CRT_DT), datepart(EVNT_DT));
	diff = days_full - days_nowknd;
	elaps2 = elaps - diff;

	/* cap */
	elaps3 = max(elaps2,0);

	if sel_appr_typ_dc = 'PhotoAppraisal' then
		elaps3 = min(elaps3,8);
	else if sel_appr_typ_dc in ('IndependentAdjuster','MaterialDamageAdjuster','OpenShop') then
		elaps3 = min(elaps3,20);
	else if sel_appr_typ_dc in ('DirectRepairProgram','EstimateDeskReview') then
		elaps3 = min(elaps3,30);
	else if sel_appr_typ_dc = 'Salvage' then
		elaps3 = min(elaps3,120);
	MAKE_NM = upcase(MAKE_NM);
	MAKE_NM2 = substr(upcase(MAKE_NM),1,4);

	/* relationship */
	if missing(DRVR_INSD_REL_TYP_DC) then
		DRVR_INSD_REL_TYP_DC = 'Other';

	/* too many levels */
	if DRVR_INSD_REL_TYP_DC in ('Self','Child','Spouse','Other','Relative') then
		DRVR_INSD_REL_TYP_DC_grp = DRVR_INSD_REL_TYP_DC;
	else if DRVR_INSD_REL_TYP_DC = 'DomesticPartner' then
		DRVR_INSD_REL_TYP_DC_grp = 'Spouse';
	else if DRVR_INSD_REL_TYP_DC = 'Parent' then
		DRVR_INSD_REL_TYP_DC_grp = 'Relative';
	else if DRVR_INSD_REL_TYP_DC = 'Grandparent' then
		DRVR_INSD_REL_TYP_DC_grp = 'Relative';
	else DRVR_INSD_REL_TYP_DC_grp = 'Other';

	/* not sure keeping */
	if VEH_STYL_DC in ('DumpTruck','BoxTruck','TractorTrailer','TractorOnly','Bus','ConstructionVehicle',
		'StraightTruck','GarbageTruck','CarTransporter','CementMixer') then
		VEH_STYL_DC_grp = 'Truck';
	else if VEH_STYL_DC in ('Boat','AllTerrainVehicle','','Snowmobile','GolfCart','Crane','RecreationalVehicle','Trailer') then
		VEH_STYL_DC_grp = 'Other';
	else VEH_STYL_DC_grp = VEH_STYL_DC;

	/* cleanup makename and group */
	if substr(upcase(MAKE_NM),1,4) in ('FORD','CHEV','TOYO','HOND','NISS','JEEP','HYUN','SUBA',
		'DODG','GMC','KIA','RAM','BUIC','LEXU','CHRY','MAZD','VOLK',
		'BMW','CADI') /* 20 most common */
	then

		do;
			make_grp = 'common';
			make_nm2 = substr(upcase(MAKE_NM),1,4);
		end;
	else
		do;
			make_grp = 'un-common';
			make_nm2 = 'OTHE';
		end;

	/* make month legit categorical */
	month = month(datepart(SVC_CRT_DT));

	if month = 1 then
		monthc = 'Jan';
	else if month = 2 then
		monthc = 'Feb';
	else if month = 3 then
		monthc = 'Mar';
	else if month = 4 then
		monthc = 'Apr';
	else if month = 5 then
		monthc = 'May';
	else if month = 6 then
		monthc = 'Jun';
	else if month = 7 then
		monthc = 'Jul';
	else if month = 8 then
		monthc = 'Aug';
	else if month = 9 then
		monthc = 'Sep';
	else if month = 10 then
		monthc = 'Oct';
	else if month = 11 then
		monthc = 'Nov';
	else if month = 12 then
		monthc = 'Dec';

	/* collision point */
	if COL_PNT_TYP_DC2 in ('Glass','Vandalized','Hail') then
		coll_pnt_grp = "superficial";
	else if COL_PNT_TYP_DC2 in ('Right rear','Left rear','Right quarter post','Left quarter post') 
		then
		coll_pnt_grp = "rear-side";
	else if COL_PNT_TYP_DC2 in ('Right front pillar','Left front pillar','Right front','Left front')
		then
		coll_pnt_grp = "frontside";
	else if COL_PNT_TYP_DC2 in ('Rear') then
		coll_pnt_grp = 'rear';
	else if COL_PNT_TYP_DC2 in ('Left T-Bone','Right T-Bone','Undercarriage') then
		coll_pnt_grp = "Tbone/Under";
	else if COL_PNT_TYP_DC2 in ('Non-collision (comprehensive loss)') then
		coll_pnt_grp = "Comp";
	else if COL_PNT_TYP_DC2 in ('Front') then
		coll_pnt_grp = "Front";
	else if COL_PNT_TYP_DC2 in ('Left & Right side','All over','Front & Rear') then
		coll_pnt_grp = "Multiple";
	else if COL_PNT_TYP_DC2 in ('Total loss','Fresh water','Engine burn','Rollover','Interior burn',
		'Total burn','Strip','Salt water','')
		then
		coll_pnt_grp = "Extensive";

	/* cleanup modelyear */
	veh_age = min(max(svc_crt_year- mfr_yr,0),25);

	/* good enough for now */
	/* Veh_USE_RSN_DC: business vs other groupings 0|1 */
	if Veh_USE_RSN_DC = 'Business' then
		Veh_USE_RSN_DC_grp = 'Business';
	else Veh_USE_RSN_DC_grp = 'Other';

	/* line of business */
	if LOB_DC = "BusinessAutoLine" then
		LOB_grp = 'BusAuto';
	else if LOB_DC = "PersonalAutoLine" then
		LOB_grp = 'PersAuto';
	else LOB_grp = 'Other';

	/*	-	Combine LIEN_LEAS_DC and make a 0|1 if Lease or Lien then 1 else 0. */
	lien_lease = 1;

	if missing(LIEN_LEAS_DC) then
		lien_lease = 0;
run;

/* need to cut this down to the variables actually used */
/* save */
data mdl_curr.for_pythonscoring;
	set mdata;
	keep 

		/* bonus for step 6 */
	ADJ_POS_DC

	/* target */
	elaps3

	/* key */
	SVC_REQ_NR
	adj_nm
	EVNT_DT

	/*# nuisance */
	USR_RPT_BRNCH_DC

	/*# vehicle info */
	veh_age
	lien_lease  
	VEH_OPR_IN
	make_grp
	VEH_STYL_DC_grp  

	/*# service area info */
	vehicles_in_20mi
	br_pos_emp_count
	drivetime 

	/*# incident info*/
	coll_pnt_grp
	DRVR_INSD_REL_TYP_DC
	LOB_grp

	/*# appraisal info*/
	SEL_APPR_TYP_DC
	monthc 

	/*# workload*/
	DirectRepairProgram  
	MaterialDamageAdjuster
	IndependentAdjuster 
	EstimateDeskReview 
	PhotoAppraisal

	/*# evaluate*/
	supplements
	has_rental

	;
run;

%macro ExportCustom();
	%if &flag. = 1 %then
		%do;
			/* excel output */
			proc export data=mdl_curr.for_pythonscoring 
				outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Material Damage/executable/Output/CBscoringv2.csv"
				dbms=csv
				replace;
			run;

		%end;
	%else
		%do;
			/* excel output */
			proc export data=mdl_curr.for_pythonscoring 
				outfile="&output_path_csv/CBscoringv2.csv"
				dbms=csv
				replace;
			run;

		%end;
%mend ExportCustom;

%ExportCustom();