--liquibase formatted sql

--changeset  usama:trigger_9 runOnChange:true stripeComments:false   splitStatements:false
-- FUNCTION: adempiere.xx_bef_empstatus_insert()

-- DROP FUNCTION IF EXISTS adempiere.xx_bef_empstatus_insert();

CREATE OR REPLACE FUNCTION adempiere.xx_bef_empstatus_insert()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
declare
	latest_ending timestamp without time zone;
	latest_record numeric;
begin

		latest_ending=(select coalesce((select case when MAX(enddate)<= MAX(startdate) then MAX(startdate)+interval '1 day' else max(enddate)+interval '1 day' end 
							   from adempiere.HR_Emp_Status where c_bpartner_id = new.c_bpartner_id
							  ),
 			  ((select startdate from adempiere.hr_employee where  c_bpartner_id = new.c_bpartner_id ) )) );
		
		new.startdate = latest_ending;
		if(new.enddate<= new.startdate) then
			new.enddate = new.startdate+interval '1 day';
		end if;
		
		
		select HR_Emp_Status_ID,enddate into latest_record ,latest_ending from adempiere.HR_Emp_Status where c_bpartner_id = new.c_bpartner_id
							order by startdate desc limit 1;

		if(latest_record is not null) then
			if(latest_ending is null) then
-- 					raise exception 'I am here = % and % ',latest_record,latest_ending;
				update adempiere.HR_Emp_Status set enddate = new.startdate where HR_Emp_Status_ID = latest_record;
			end if;
		end if;
			
			
			update adempiere.hr_employee set HR_Emp_StatusType_ID = new.HR_Emp_StatusType_ID where c_bpartner_id = new.c_bpartner_id;
		
		
		
		
		
RETURN NEW;
END;
$BODY$;

ALTER FUNCTION adempiere.xx_bef_empstatus_insert()
    OWNER TO adempiere;
