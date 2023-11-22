--liquibase formatted sql

--changeset  usama:trigger_1 runOnChange:true stripeComments:false splitStatements:false
-- FUNCTION: adempiere.before_lev_delete()

-- DROP FUNCTION IF EXISTS adempiere.before_lev_delete();

CREATE OR REPLACE FUNCTION adempiere.before_lev_delete()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
declare 
unit numeric;
unit2 numeric;
unit3 numeric;
begin
		
		select nduration into unit
		from adempiere.hr_emplev_posting
		where hr_emplev_posting_id = old.hr_emplev_posting_id;
		update adempiere.hr_emplev_bal set availed = availed - unit
		where c_bpartner_id = old.c_bpartner_id and hr_levtypes_id = old.ded_against and c_year_id = old.c_year_id;
		
		return old;
end;
$BODY$;

ALTER FUNCTION adempiere.before_lev_delete()
    OWNER TO adempiere;
