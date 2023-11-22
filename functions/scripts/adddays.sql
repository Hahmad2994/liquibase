-- FUNCTION: adempiere.adddays(timestamp with time zone, numeric)

-- DROP FUNCTION IF EXISTS adempiere.adddays(timestamp with time zone, numeric);

CREATE OR REPLACE FUNCTION adempiere.adddays(
	datetime timestamp with time zone,
	days numeric)
    RETURNS timestamp with time zone
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
BEGIN
	if datetime is null or days is null then
		return null;
	end if;
	return datetime + (interval '1' second * (86400 * days));
END;
$BODY$;

ALTER FUNCTION adempiere.adddays(timestamp with time zone, numeric)
    OWNER TO adempiere;
