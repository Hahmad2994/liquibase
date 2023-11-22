-- FUNCTION: adempiere.xxsettlementprocess(numeric, numeric, numeric, numeric, numeric)

-- DROP FUNCTION IF EXISTS adempiere.xxsettlementprocess(numeric, numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION adempiere.xxsettlementprocess(
	p_bpartner_id numeric,
	p_client_id numeric,
	p_org_id numeric,
	p_user_id numeric,
	p_period_id numeric)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_bpartner	numeric;
	v_hremp		numeric;
	v_empstart	timestamp without time zone;
	v_empend	timestamp without time zone;
	v_clientid	numeric;
	v_orgid		numeric;
	v_yearid	numeric;
	
	v_seq_id	numeric;
	v_current	numeric;
	
	gross_salary1 numeric;
	b_salary1 numeric;
	h_rent1 numeric;
	utilities1 numeric;

	gross_salary numeric;
	b_salary numeric;
	h_rent numeric;
	utilities numeric;
	w_days numeric;
	
	mobile_usage numeric;
	vehicle_maintain numeric;
	fixed_allowance numeric;
	da_rate numeric;
	da_rate1 numeric;
	da_amount numeric;
	da_amount1 numeric;
	ta_rate numeric;
	ta_rate1 numeric;
	ta_amount numeric;
	ta_amount1 numeric;
	night_stay numeric;
	night_stay1 numeric;
	no_leave numeric;
	no_leave_amt numeric;
	remain_leave numeric;
	leave_amount numeric;
	pf_e_cont numeric;
	pf_er_cont numeric;
	commission numeric;
	adv_salary numeric;
	adv_exp numeric;
	stl_amt numeric;
	other_ded numeric;
	mobile_excess numeric;
	late_ded numeric;
	da_km numeric;
	ta_km numeric;
	da_days numeric;
	ta_days numeric;
	p_days numeric;
	mobile_usage1 numeric;
	v_main1 numeric;
	v_rent1 numeric;
	fuel1 numeric;	
	vehicle_rent numeric;
	v_gratuity numeric;
	v_vps numeric;
	v_other_add numeric;
	v_piece_rate numeric;
	v_uniform numeric;
	v_hr_period_id numeric;
	
	emprecord	RECORD;
	rec   		RECORD;
	frec		RECORD;
	
	emp_info	CURSOR (cbpartnerid numeric) FOR SELECT * FROM adempiere.xxhr_employee_v WHERE ad_client_id = COALESCE(p_client_id, ad_client_id) AND ad_org_id = COALESCE(p_org_id, ad_org_id) AND c_bpartner_id = cbpartnerid ORDER BY hr_department_id, c_bpartner_id;
	sal_info	CURSOR (s_period numeric, s_concept numeric, cbpartnerid numeric) FOR SELECT * FROM adempiere.hr_movement WHERE ad_client_id = COALESCE(p_client_id, ad_client_id) AND ad_org_id = COALESCE(p_org_id, ad_org_id) AND c_bpartner_id = cbpartnerid AND hr_concept_id = s_concept AND hr_period_id = s_period ORDER BY hr_department_id, c_bpartner_id;
 BEGIN
 	OPEN emp_info(p_bpartner_id);
 	LOOP
	raise notice 'I came into loop';
		FETCH emp_info INTO rec;
		EXIT WHEN NOT FOUND;
		raise notice 'record found';
			v_bpartner	:= rec.c_bpartner_id;
			v_hremp		:= rec.hr_employee_id;
			v_empstart	:= rec.startdate;
			v_empend	:= rec.enddate;
			v_clientid	:= rec.ad_client_id;
			v_orgid		:= rec.ad_org_id;
			------------
			DELETE FROM adempiere.hr_finalsettlement WHERE c_bpartner_id = v_bpartner;
			-------------
			SELECT c_year_id INTO v_yearid FROM adempiere.c_period WHERE ad_client_id = v_clientid AND v_empend::date BETWEEN startdate::date AND enddate::date LIMIT 1;
		--	SELECT hr_period_id INTO p_period_id FROM adempiere.hr_period WHERE ad_client_id = v_clientid AND v_empend::date BETWEEN startdate::date AND enddate::date LIMIT 1;
			
			SELECT (enddate::date - startdate::date) + 1 INTO p_days FROM adempiere.hr_period WHERE hr_period_id = p_period_id;
			gross_salary := rec.gross_salary;
			raise notice 'Gross = %',rec.gross_salary;
			b_salary	 := (rec.gross_salary * 66) / 100;
-- 			h_rent		 := (b_salary * 24) / 100;
-- 			utilities	 := (b_salary * 10) / 100;
			h_rent		 := (rec.gross_salary * 24) / 100;
			utilities	 := (rec.gross_salary * 10) / 100;
			da_rate		 := COALESCE(rec.da_local, 0);
			ta_rate		 := COALESCE(rec.ta_local, 0);
			da_rate1	 := COALESCE(rec.da_outback, 0);
			ta_rate1	 := COALESCE(rec.ta_outstation, 0);	
			vehicle_rent := COALESCE(rec.vehicle_rent, 0);
			v_gratuity :=0;
			if rec.vps = 0 then
			v_gratuity := (select (round(case when (enddate::date  - startdate::date)/365.00 >1 then (enddate::date  - startdate::date)/365.00 else 0 end)) * rec.gross_salary from adempiere.hr_employee where c_bpartner_id =rec.c_bpartner_id);
			end if;
			v_other_add :=0;
			select (pc_1000034) into v_piece_rate from adempiere.hr_salaryinfo where ad_client_id = rec.ad_client_id and  c_bpartner_id = rec.c_bpartner_id;
			v_uniform:=0;
			select SUM(pc_1000028) into v_vps from adempiere.hr_salaryinfo where ad_client_id = rec.ad_client_id and  c_bpartner_id = rec.c_bpartner_id and adempiere.hr_salaryinfo.hr_period_id <> p_period_id;
			
			SELECT COALESCE(amount,0) INTO da_days FROM adempiere.hr_salary_entry WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000008;
			SELECT COALESCE(amount,0) INTO da_km FROM adempiere.hr_salary_entry WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000009;
			SELECT COALESCE(amount,0) INTO ta_days FROM adempiere.hr_salary_entry WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000010;
			SELECT COALESCE(amount,0) INTO ta_km FROM adempiere.hr_salary_entry WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000011;
			raise notice 'BP_ID = % and Period = % ',rec.c_bpartner_id,p_period_id;
			SELECT COALESCE(pc_1000006,0) INTO w_days FROM adempiere.hr_salaryinfo WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id ;
			raise notice 'Wdays calculated above are %',w_days;
			SELECT COALESCE(amount,0) INTO gross_salary1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000002;
			SELECT COALESCE(amount,0) INTO b_salary1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000003;
			SELECT COALESCE(amount,0) INTO h_rent1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000004;
			SELECT COALESCE(amount,0) INTO utilities1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000005;
			SELECT COALESCE(amount,0) INTO mobile_usage FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id = 1000007;
			SELECT COALESCE(amount,0) INTO vehicle_maintain FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000013, 1000014);
			SELECT COALESCE(amount,0) INTO fixed_allowance FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000012);
			SELECT COALESCE(amount,0) INTO da_amount FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000008);
			SELECT COALESCE(amount,0) INTO ta_amount FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000011);
			SELECT COALESCE(amount,0) INTO da_amount1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000009);
			SELECT COALESCE(amount,0) INTO ta_amount1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000012);
			SELECT COALESCE(amount,0) INTO night_stay FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000018);
			SELECT COALESCE(amount,0) INTO night_stay1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000017);
			SELECT COALESCE(amount,0) INTO commission FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000015);
			
			SELECT COALESCE(amount,0) INTO mobile_usage1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000007);
			SELECT COALESCE(amount,0) INTO fuel1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000012);
			SELECT COALESCE(amount,0) INTO v_main1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000013);
			SELECT COALESCE(amount,0) INTO v_rent1 FROM adempiere.hr_movement WHERE c_bpartner_id = rec.c_bpartner_id AND hr_period_id = p_period_id AND hr_concept_id IN (1000014);
			
			
			no_leave := 0;
			no_leave_amt := 0;
			
			remain_leave := 0;
			
			SELECT COALESCE(SUM(balanced),0) INTO remain_leave FROM 
					(SELECT *, ((COALESCE(open_bal, 0) + COALESCE(total,0)) - (COALESCE(vavailed, 0) + COALESCE(inqued, 0) + COALESCE(encashed, 0) + COALESCE(adjusted,0))) as balanced
					FROM (
						SELECT lp.hr_emplev_bal_id, lp.open_bal, lp.total, lp.availed, lp.inqued, lp.encashed, lp.adjusted, lp.c_bpartner_id, lt.hr_levtypes_id, lt.value alias, lt.name leavedesc, lt.description, lt.isbalanced, lt.ischkbal, lt.isdeducted, lt.unittype, lt.attbalwd, lt.att_levtype_id, lt.maxleaves
						, ((COALESCE(lp.open_bal, 0) + COALESCE(lp.total,0)) - (COALESCE(lp.availed, 0) + COALESCE(lp.inqued, 0) + COALESCE(lp.encashed, 0) + COALESCE(lp.adjusted,0))) as balance
						, (SELECT name FROM adempiere.c_bpartner WHERE c_bpartner_id = lp.c_bpartner_id) as partnername
						, (SELECT 'Leave Balance For The Year <b> ' || fiscalyear || '</b>' FROM adempiere.c_year WHERE c_year_id = lp.c_year_id) as yearshow
						, 0 as prorata, COALESCE((SELECT SUM(nduration) FROM adempiere.hr_emplev_posting WHERE c_bpartner_id = lp.c_bpartner_id AND c_year_id = lp.c_year_id AND hr_levtypes_id = lt.hr_levtypes_id),0) 
						+ COALESCE((SELECT SUM(nduration) FROM adempiere.hr_emplev_posting WHERE c_bpartner_id = lp.c_bpartner_id AND c_year_id = lp.c_year_id AND hr_levtypes_id IN (SELECT hr_levtypes_id FROM adempiere.hr_levtypes WHERE att_levtype_id = lt.hr_levtypes_id)),0) 
						+ COALESCE(lp.availed, 0) as vavailed
						FROM adempiere.hr_emplev_bal lp, adempiere.hr_levtypes lt
						WHERE lt.ad_client_id   = lp.ad_client_id --and lt.HR_LevTypes_ID=1000001
 AND lp.hr_levtypes_id = lt.hr_levtypes_id
  						AND lp.c_bpartner_id  = v_bpartner AND lp.c_year_id = v_yearid) a) q;
			raise notice 'Remain Leave = %',remain_leave;
			--leave_amount := (rec.gross_salary / 30) * COALESCE(remain_leave,0);
			
			pf_e_cont := 0;
			pf_er_cont := 0;

			adv_salary := 0;
			SELECT (COALESCE(loanamount,0) - COALESCE(amtrecvd,0)) INTO adv_salary FROM adempiere.xxadvanceview WHERE c_bpartner_id = v_bpartner;
			adv_exp := 0;
			stl_amt := 0;
			SELECT (COALESCE(loanamount,0) - COALESCE(amtrecvd,0)) INTO stl_amt FROM adempiere.xxloanview WHERE c_bpartner_id = v_bpartner;
			other_ded := 0;
			mobile_excess := 0;
			late_ded := 0;
			raise notice 'Wdays calculated below are %',w_days;
			--------------------------- INSERTION
			SELECT ad_sequence_id, currentnext INTO v_seq_id, v_current FROM adempiere.AD_Sequence WHERE name = 'HR_FinalSettlement';
			INSERT INTO adempiere.hr_finalsettlement(hr_finalsettlement_id, ad_client_id, ad_org_id, code, name, c_bpartner_id, hr_employee_id,
						created, createdby, isactive, startdate, enddate, updated, updatedby, gross_salary, b_salary, w_days, h_rent, utilities,
    					mobile_usage, vehicle_maintain, fixed_allowance, da_rate, da_amount, ta_rate, ta_amount, night_stay, no_leave, no_leave_amt,
						remain_leave, leave_amount, pf_e_cont, pf_er_cont, commission, adv_salary, adv_exp, stl_amt, other_ded, mobile_excess,
					 	late_ded, gross_salary1, b_salary1, h_rent1, da_rate1, ta_rate1, night_stay1, utilities1, da_amount1, ta_amount1, ta_km,
						da_km, da_days, ta_days, mobile_usage1, v_main1, v_rent1, fuel1, vehicle_rent,gratuity,vps,other_add,piece_rate,uniform_ded,hr_period_id)
			VALUES (v_current, v_clientid, v_orgid, '', '', v_bpartner, v_hremp,
						now(), 1000000, 'Y', v_empstart, v_empend, now(), 1000000, COALESCE(gross_salary,0), COALESCE(b_salary,0), COALESCE(w_days,0)
						, COALESCE(h_rent,0), COALESCE(utilities,0),COALESCE(mobile_usage,0), COALESCE(vehicle_maintain,0), COALESCE(fixed_allowance,0)
						, COALESCE(da_rate,0), COALESCE(da_amount,0), COALESCE(ta_rate,0), COALESCE(ta_amount,0), COALESCE(night_stay,0), COALESCE(no_leave,0)
					 	, COALESCE(no_leave_amt,0),	COALESCE(remain_leave,0), COALESCE(leave_amount,0), COALESCE(pf_e_cont,0), COALESCE(pf_er_cont,0), COALESCE(commission,0)
						, COALESCE(adv_salary,0), COALESCE(adv_exp,0), COALESCE(stl_amt,0), COALESCE(other_ded,0), COALESCE(mobile_excess,0)
						, COALESCE(late_ded,0), COALESCE(gross_salary1,0), COALESCE(b_salary1,0), COALESCE(h_rent1,0), COALESCE(da_rate1,0)
						, COALESCE(ta_rate1,0), COALESCE(night_stay1,0), COALESCE(utilities1,0), COALESCE(da_amount1,0), COALESCE(ta_amount1,0)
						, COALESCE(ta_km,0), COALESCE(da_km,0), COALESCE(da_days,0), COALESCE(ta_days,0), COALESCE(mobile_usage1,0), COALESCE(v_main1,0)
						, COALESCE(v_rent1,0), COALESCE(fuel1,0), COALESCE(vehicle_rent, 0),COALESCE(v_gratuity, 0),COALESCE(v_vps, 0),COALESCE(v_other_add,0),COALESCE(v_piece_rate,0),COALESCE(v_uniform,0),COALESCE(p_period_id,0));
			UPDATE adempiere.AD_Sequence SET currentnext = v_current + 1 WHERE name = 'HR_FinalSettlement' AND ad_sequence_id = v_seq_id;
			--------------------------- INSERTION
			----------------------------
			-- RAISE NOTICE 'WDays %', w_days;
			-- RAISE NOTICE 'Gross %, Basic %, Rent %, Utility %', gross_salary1, b_salary1, h_rent1, utilities1;
			-- RAISE NOTICE 'Employee Start Date %, End Date %', v_empstart, v_empend;
			----------------------------
	END LOOP;
	RETURN TRUE;
 END;
$BODY$;

ALTER FUNCTION adempiere.xxsettlementprocess(numeric, numeric, numeric, numeric, numeric)
    OWNER TO adempiere;
