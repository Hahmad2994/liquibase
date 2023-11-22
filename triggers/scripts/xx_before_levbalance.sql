--liquibase formatted sql

--changeset  usama:trigger_15 runOnChange:true stripeComments:false   splitStatements:false
-- FUNCTION: adempiere.xx_before_levbalance()

-- DROP FUNCTION IF EXISTS adempiere.xx_before_levbalance();

CREATE OR REPLACE FUNCTION adempiere.xx_before_levbalance()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	v_hrEmployee numeric;
BEGIN
	SELECT hr_employee_id INTO v_hrEmployee FROM adempiere.hr_Employee WHERE C_BPartner_ID = NEW.C_BPartner_ID ORDER BY C_BPartner_ID LIMIT 1;
NEW.hr_employee_id = v_hrEmployee;
RETURN NEW;
END;

$BODY$;

ALTER FUNCTION adempiere.xx_before_levbalance()
    OWNER TO adempiere;
