--liquibase formatted sql

--changeset  usama:trigger_12 runOnChange:true stripeComments:false   splitStatements:false
-- FUNCTION: adempiere.xx_before_employeesal()

-- DROP FUNCTION IF EXISTS adempiere.xx_before_employeesal();

CREATE OR REPLACE FUNCTION adempiere.xx_before_employeesal()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	vSalary		numeric = 0;
	vBasic		numeric = 0;
	vHouse		numeric = 0;
	vConv		numeric = 0;
	vUtil		numeric = 0;
	vmedical	numeric = 0;
	
	pBasic		numeric = (2.0/3.0)*100;
-- 	pHouse		numeric = 15;
	pHouse		numeric = 40;
	pConv		numeric = 8;
-- 	pUtil		numeric = 5;
	pUtil		numeric = 10;
	pmedical	numeric = 5;
BEGIN

-- 	raise exception 'New = %, Old = %', NEW.gross_salary , OLD.gross_salary;
	IF (TG_OP = 'UPDATE') THEN
		IF NEW.gross_salary <> OLD.gross_salary THEN
-- 		raise exception 'I cam here';
			vSalary = NEW.gross_salary;
		-- COLA Adjustment WITH 100
			IF vSalary > 0 THEN
				--vSalary = vSalary - 100;
				vBasic = vSalary * pBasic / 100; -- Basic Salary
				--vHouse = vSalary * pHouse / 100; -- House Rent
				vHouse = vBasic * pHouse / 100; -- House Rent
				vConv = vSalary * pConv / 100; -- Convancey Allowance
-- 				vUtil = vSalary * pUtil / 100; -- Utility
				vUtil = vBasic * pUtil / 100; -- Utility
				vmedical = vSalary * pmedical / 100; -- Medical
						NEW.basic_salary = CEIL(round(vBasic,2));
		-- 		NEW.conv_allow = ROUND(vConv,2);
		-- 		NEW.medical_allow = ROUND(vmedical,2);
				NEW.utility_allow = FLOOR(round(vUtil,2));
				NEW.house_allow = FLOOR(round(vHouse,2));
				END IF;
-- 				raise exception 'Gross = % , Basic = % , Utility = % , House = %',vSalary,NEW.basic_salary,NEW.utility_allow,NEW.house_allow;
				if(NEW.basic_salary+NEW.utility_allow+NEW.house_allow <> vSalary ) then
					NEW.basic_salary = vSalary - (NEW.utility_allow+NEW.house_allow);
				end if;
			END IF;

		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		vSalary = NEW.gross_salary;
		-- COLA Adjustment WITH 100
		IF vSalary > 0 THEN
			vBasic = vSalary * pBasic / 100; -- Basic Salary
				--vHouse = vSalary * pHouse / 100; -- House Rent
				vHouse = vBasic * pHouse / 100; -- House Rent
				vConv = vSalary * pConv / 100; -- Convancey Allowance
-- 				vUtil = vSalary * pUtil / 100; -- Utility
				vUtil = vBasic * pUtil / 100; -- Utility
				vmedical = vSalary * pmedical / 100; -- Medical
				NEW.basic_salary = CEIL(round(vBasic,2));
		-- 		NEW.conv_allow = ROUND(vConv,2);
		-- 		NEW.medical_allow = ROUND(vmedical,2);
				NEW.utility_allow = FLOOR(round(vUtil,2));
				NEW.house_allow = FLOOR(round(vHouse,2));
				if(NEW.basic_salary+NEW.utility_allow+NEW.house_allow <> vSalary ) then
					NEW.basic_salary = vSalary - NEW.utility_allow+NEW.house_allow;
				end if;
				
		END IF;
		RETURN NEW;
	END IF;
END;

$BODY$;

ALTER FUNCTION adempiere.xx_before_employeesal()
    OWNER TO adempiere;
