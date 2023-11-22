-- FUNCTION: adempiere.xxyearlyabsentregister(numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying, numeric, numeric, numeric)

-- DROP FUNCTION IF EXISTS adempiere.xxyearlyabsentregister(numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION adempiere.xxyearlyabsentregister(
	p_year_id numeric,
	p_bpartner_id numeric,
	p1_id numeric,
	p2_id numeric,
	p_client_id numeric,
	p_org_id numeric,
	p_rtype numeric,
	p_rtype1 character varying,
	p_emp_statustype_id numeric,
	p_city_id numeric,
	p_salesregion_id numeric)
    RETURNS TABLE(rgroup character varying, sgroup character varying, clientname character varying, orgname character varying, c_bpartner_id numeric, empcode character varying, empname character varying, designation character varying, startdate timestamp without time zone, grade_detail character varying, empstatus character varying, m1 double precision, m2 double precision, m3 double precision, m4 double precision, m5 double precision, m6 double precision, m7 double precision, m8 double precision, m9 double precision, m10 double precision, m11 double precision, m12 double precision, yr1 numeric, yr2 numeric, department character varying, subdepart character varying, emplocation character varying, postcity character varying, levtotal numeric, zone_desc character varying, levavail numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$

DECLARE
	var_r 	record;
	v_year	numeric;
	v_year1	numeric;
BEGIN
	SELECT EXTRACT(Year From cc.startdate::date)::numeric INTO v_year FROM adempiere.c_period cc WHERE c_year_id = p_year_id AND EXTRACT(Month From cc.startdate::date) = 7 LIMIT 1;
	SELECT EXTRACT(Year From cc.startdate::date)::numeric INTO v_year1 FROM adempiere.c_period cc WHERE c_year_id = p_year_id AND EXTRACT(Month From cc.startdate::date) = 1 LIMIT 1;
	
	FOR var_r IN( 
				SELECT CASE WHEN COALESCE(p_rtype, 0) = 1 THEN emp.emplocation ELSE emp.departmet END as rGroup
	, CASE WHEN COALESCE(p_rtype, 0) = 1 THEN emp.postcity ELSE emp.subdeptname END as sGroup
	, emp.clientname, emp.orgname, emp.c_bpartner_id, emp.empcode, emp.empname, emp.designation
	, emp.startdate, emp.grade_detail, emp.empstatus
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 7 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m1
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 8 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m2
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 9 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m3
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 10 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m4
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 11 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m5
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 12 AND EXTRACT(Year from attdate::date) = v_year),0)::double precision as m6
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 1 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m7
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 2 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m8
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 3 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m9
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 4 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m10
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 5 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m11
	, COALESCE((SELECT count(hr_final_attend.c_bpartner_id) FROM adempiere.hr_final_attend WHERE hr_final_attend.c_bpartner_id = emp.c_bpartner_id AND hr_final_attend.c_year_id = p_year_id AND attstatus IN ('A','AB') AND EXTRACT(Month from attdate::date) = 6 AND EXTRACT(Year from attdate::date) = v_year1),0)::double precision as m12
	, COALESCE(v_year,0) yr1, COALESCE(v_year1,0) yr2, emp.departmet, emp.subdeptname, emp.emplocation, emp.postcity
	, COALESCE((SELECT total FROM adempiere.hr_emplev_bal WHERE hr_emplev_bal.c_bpartner_id = emp.c_bpartner_id AND hr_emplev_bal.c_year_id = p_year_id AND hr_emplev_bal.hr_levtypes_id IN (1000001) AND total > 0 LIMIT 1),0)::double precision as levtotal
	, COALESCE((SELECT availed FROM adempiere.hr_emplev_bal WHERE hr_emplev_bal.c_bpartner_id = emp.c_bpartner_id AND hr_emplev_bal.c_year_id = p_year_id AND hr_emplev_bal.hr_levtypes_id IN (1000001) AND availed > 0 LIMIT 1),0)::double precision as levavail
	, emp.zone_desc
	FROM adempiere.xxhr_employee_v emp
	WHERE emp.c_bpartner_id = COALESCE(p_bpartner_id, emp.c_bpartner_id)
	  AND emp.ad_client_id = p_client_id
	  AND emp.ad_org_id = COALESCE(p_org_id, emp.ad_org_id)
	  AND emp.hr_emplocation_id = COALESCE(p1_id, emp.hr_emplocation_id) 
	  AND emp.hr_department_id = COALESCE(p2_id, emp.hr_department_id)
	  AND emp.hr_emp_statustype_id = COALESCE(p_Emp_StatusType_ID, emp.hr_emp_statustype_id)
	  AND emp.c_city_id = COALESCE(p_city_id, emp.c_city_id)
	  AND (CASE WHEN COALESCE(p_salesregion_id, 0) > 0 THEN emp.C_SalesRegion_ID = p_salesregion_id ELSE 1 = 1 END)
	  --AND emp.c_salesregion_id = COALESCE(p_salesregion_id, emp.c_salesregion_id)
 	  AND (CASE WHEN p_rtype1 = 'Active' THEN emp.enddate IS NULL WHEN p_rtype1 = 'In-Active' THEN emp.enddate IS NOT NULL ELSE (emp.enddate IS NULL OR emp.enddate::date <= now()::date) END)
	  ORDER BY emp.emplocation, emp.postcity, emp.empcode
	)
	LOOP
		rgroup := var_r.rgroup; 
		sgroup := var_r.sgroup; 
		clientname := var_r.clientname;
		orgname := var_r.orgname;
		c_bpartner_id := var_r.c_bpartner_id;
		empcode := var_r.empcode;
		empname := var_r.empname;
		designation := var_r.designation;
		startdate := var_r.startdate;
		grade_detail := var_r.grade_detail;
		empstatus := var_r.empstatus;
		m1 := var_r.m1;
		m2 := var_r.m2;
		m3 := var_r.m3;
		m4 := var_r.m4;
		m5 := var_r.m5;
		m6 := var_r.m6;
		m7 := var_r.m7;
		m8 := var_r.m8;
		m9 := var_r.m9;
		m10 := var_r.m10;
		m11 := var_r.m11;
		m12 := var_r.m12;
		yr1 := var_r.yr1;
		yr2 := var_r.yr2;
		department := var_r.departmet;
		subdepart := var_r.subdeptname;
		emplocation := var_r.emplocation;
		postcity := var_r.postcity;
		--levtotal := var_r.levtotal;
		levtotal := abs(m1) +abs(m2) + abs(m3) +abs(m4) + abs(m5) +abs( m6) +abs( m7) + abs(m8) + abs(m9)+ abs(m10)+ abs(m11)+ abs(m12);
		
		zone_desc := var_r.zone_desc;
		levavail := var_r.levavail;
	RETURN NEXT;
   END LOOP;

END;

$BODY$;

ALTER FUNCTION adempiere.xxyearlyabsentregister(numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying, numeric, numeric, numeric)
    OWNER TO adempiere;
