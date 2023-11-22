-- FUNCTION: adempiere.xxdailyattend_manual(numeric, character varying, character varying, numeric)

-- DROP FUNCTION IF EXISTS adempiere.xxdailyattend_manual(numeric, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION adempiere.xxdailyattend_manual(
	p_master_id numeric,
	p_machine_id character varying,
	p_mydate character varying,
	p_opt numeric)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_start		date;
	v_end		date;
	curr_date	date;
	v_seq_id	numeric;
	v_current	numeric;
	v_lineno	numeric = 10;
	v_hrEmployee numeric;
	v_bpart	 	 numeric;
	v_client	 numeric;
	v_org		 numeric;
	v_Machine 	 character varying(50);
	v_date		 character varying(50);
	v_time		 character varying(50);
	v_year		 numeric;
	v_att		 numeric;
	v_Machine_id numeric;
BEGIN
	--SELECT startdate::date, enddate::date INTO v_start, v_end FROM adempiere.hr_period WHERE hr_period_id = p_period_id;
	--SELECT * FROM adempiere.AD_Sequence WHERE name = 'HR_Daily_Attend'
	SELECT ad_sequence_id, currentnext INTO v_seq_id, v_current FROM adempiere.AD_Sequence WHERE name = 'HR_Daily_Attend';
	--SELECT c_bpartner_id INTO v_bpart FROM adempiere.c_bpartner WHERE LIMIT 1;
	--SELECT ipaddr INTO v_Machine FROM adempiere.hr_attMachines WHERE hr_attMachines_id = p_machine_id LIMIT 1;
	SELECT hr_attMachines_id INTO v_Machine_id FROM adempiere.hr_attMachines WHERE ipaddr = p_machine_id LIMIT 1;
-- 	RAISE NOTICE ' Machine ID %', v_Machine_id;
	SELECT c_bpartner_id INTO v_bpart FROM adempiere.hr_employee WHERE machine_code =  p_master_id::character varying ORDER BY C_BPartner_ID LIMIT 1;
	select c_bpartner_id INTO v_bpart FROM adempiere.c_bpartner where value = p_master_id::character varying limit 1;																					   
	RAISE NOTICE ' v_bpart ID %', v_bpart;
	
	IF COALESCE(v_bpart, 0) = 0 THEN
	RAISE NOTICE ' v_bpart ID %', v_bpart;
	
		RETURN FALSE;
	END IF;
	--'2018-08-07 15:10'
	--RAISE NOTICE 'Year % / Month % / Day %', substring(p_mydate from 1 for 4), substring(p_mydate from 6 for 2), substring(p_mydate from 9 for 2);
	--v_time = substring(p_mydate from 6 for 2);
	--v_time = v_time || '/' || substring(p_mydate from 9 for 2);
	--v_time = v_time || '/' || substring(p_mydate from 1 for 4);
	--v_time = v_time || ' ' || substring(p_mydate from 12 for 2);
	--v_time = v_time || ':' || substring(p_mydate from 15 for 2);
	--08/29/2019 08:30
	v_time = substring(p_mydate from 6 for 2);
	v_time = v_time || '/' || substring(p_mydate from 9 for 2);
	v_time = v_time || '/' || substring(p_mydate from 1 for 4);
	v_time = v_time || ' ' || substring(p_mydate from 12 for 2);
	v_time = v_time || ':' || substring(p_mydate from 15 for 2);
	
	
	--RAISE NOTICE 'Date %', p_mydate;
	SELECT hr_daily_attend_id INTO v_att FROM adempiere.hr_daily_attend WHERE c_bpartner_id = v_bpart AND atttime = v_time::timestamp without time zone;
	IF COALESCE(v_att, 0) > 0 THEN
		RAISE NOTICE 'Already fetch %', v_att;
	
		RETURN FALSE;
	END IF;
	--IF p_machine_id = 1000000 THEN
	SELECT hr_employee_id, ad_client_id, ad_org_id INTO v_hrEmployee, v_client, v_org FROM adempiere.hr_Employee WHERE c_bpartner_id = v_bpart ORDER BY C_BPartner_ID LIMIT 1;
	--ELSE
	--	SELECT hr_employee_id, c_bpartner_id, ad_client_id, ad_org_id INTO v_hrEmployee, v_bpart, v_client, v_org FROM adempiere.hr_Employee WHERE machine2 = p_master_id::character varying ORDER BY C_BPartner_ID LIMIT 1;
	--END IF;
	IF COALESCE(v_hrEmployee, 0) = 0 THEN
		RETURN FALSE;
	END IF;
	--v_date = substring(p_mydate from 6 for 2);
	--v_date = v_date || '/' || substring(p_mydate from 9 for 2);
	--v_date = v_date || '/' || substring(p_mydate from 1 for 4);
		
	--v_time = substring(p_mydate from 6 for 2);
	--v_time = v_time || '/' || substring(p_mydate from 9 for 2);
	--v_time = v_time || '/' || substring(p_mydate from 1 for 4);
	--v_time = v_time || ' ' || substring(p_mydate from 12 for 2);
	--v_time = v_time || ':' || substring(p_mydate from 15 for 2);
	
	SELECT c_year_id INTO v_year FROM adempiere.c_period WHERE now()::date BETWEEN startdate::date AND enddate::date AND ad_client_id = 1000000 ORDER BY 1 LIMIT 1;
	IF COALESCE(v_year,0) = 0 THEN
		SELECT c_year_id INTO v_year FROM adempiere.c_period WHERE ad_client_id = 1000000 ORDER BY 1 LIMIT 1;
	END IF;
	--hr_attmachines_id, v_Machine_id,
	INSERT INTO adempiere.hr_daily_attend (hr_daily_attend_id, ad_client_id, ad_org_id, isactive, created, createdby, updated, updatedby, c_bpartner_id, c_year_id, attstatus, attactivity, mycondate, hr_daily_attend_uu)
	VALUES(v_current, v_client, v_org, 'Y', now(), 1000000, now(), 1000000, v_bpart, v_year, CASE WHEN p_opt = 0 THEN 'IN' ELSE 'OUT' END, '000', v_time,  uuid_in(md5(random()::text || clock_timestamp()::text)::cstring));

	--RAISE NOTICE 'Start Date % End Date %', v_start, v_end;
	UPDATE adempiere.AD_Sequence SET currentnext = v_current + 1 WHERE name = 'HR_Daily_Attend' AND ad_sequence_id = v_seq_id;
	RETURN TRUE;
END;
$BODY$;

ALTER FUNCTION adempiere.xxdailyattend_manual(numeric, character varying, character varying, numeric)
    OWNER TO adempiere;
