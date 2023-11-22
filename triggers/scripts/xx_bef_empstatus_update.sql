--liquibase formatted sql

--changeset  usama:trigger_10 runOnChange:true stripeComments:false   splitStatements:false
-- FUNCTION: adempiere.xx_bef_empstatus_update()

-- DROP FUNCTION IF EXISTS adempiere.xx_bef_empstatus_update();

CREATE OR REPLACE FUNCTION adempiere.xx_bef_empstatus_update()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
declare
begin
	if(new.enddate <> old.enddate or new.startdate <> old.startdate) then
	new.enddate = old.enddate;
	new.startdate = old.startdate;
	end if;
	
RETURN NEW;
END;
$BODY$;

ALTER FUNCTION adempiere.xx_bef_empstatus_update()
    OWNER TO postgres;
