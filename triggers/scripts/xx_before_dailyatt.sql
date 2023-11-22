--liquibase formatted sql

--changeset  usama:trigger_11 runOnChange:true stripeComments:false   splitStatements:false
-- FUNCTION: adempiere.xx_before_dailyatt()

-- DROP FUNCTION IF EXISTS adempiere.xx_before_dailyatt();

CREATE OR REPLACE FUNCTION adempiere.xx_before_dailyatt()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	v_hrEmployee numeric;
	v_date		 character varying(50);
	v_time		 character varying(50);
BEGIN
	SELECT hr_employee_id INTO v_hrEmployee FROM adempiere.hr_Employee WHERE C_BPartner_ID = NEW.C_BPartner_ID ORDER BY C_BPartner_ID LIMIT 1;
	NEW.hr_employee_id = v_hrEmployee;
	IF NEW.attactivity = '0' THEN
		NEW.attactivity = to_char(NEW.attactivity, 'fm000');
	END IF;
	IF NEW.myConDate IS NOT NULL THEN
		v_date = substring(NEW.myConDate from 1 for 2);
		v_date = v_date || '/' || substring(NEW.myConDate from 4 for 2);
		v_date = v_date || '/' || substring(NEW.myConDate from 7 for 4);
		
		v_time = substring(NEW.myConDate from 1 for 2);
		v_time = v_time || '/' || substring(NEW.myConDate from 4 for 2);
		v_time = v_time || '/' || substring(NEW.myConDate from 7 for 4);
		v_time = v_time || ' ' || substring(NEW.myConDate from 12 for 2);
		v_time = v_time || ':' || substring(NEW.myConDate from 15 for 2);
		
		NEW.attdate = v_date::date;
		NEW.atttime = v_time::timestamp without time zone;
		
		
	--	v_date = substring(NEW.myConDate from 1 for 10); --substring(NEW.myConDate from 1 for 2);
	
	--	v_time = NEW.myConDate; --substring(NEW.myConDate from 1 for 2);
		
		
		
	END IF;
RETURN NEW;
END;
$BODY$;

ALTER FUNCTION adempiere.xx_before_dailyatt()
    OWNER TO adempiere;
