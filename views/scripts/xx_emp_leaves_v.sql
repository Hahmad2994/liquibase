--liquibase formatted sql

--changeset  usama:view_31 runOnChange:true stripeComments:false

-- View: adempiere.xx_emp_leaves_v

-- DROP VIEW adempiere.xx_emp_leaves_v;

CREATE OR REPLACE VIEW adempiere.xx_emp_leaves_v
 AS
 SELECT emp.ad_client_id,
    emp.ad_org_id,
    emp.c_bpartner_id,
    emp.empcode,
    emp.empname,
    emp.hr_employee_id,
    emp.hr_department_id,
    emp.hr_job_id,
    emp.startdate,
    emp.enddate,
    emp.date_birth,
    emp.grade,
    emp.maritalstatus,
    emp.age,
    emp.father_name,
    emp.pmdccode,
    emp.hr_subdepartment_id,
    emp.departmet,
    emp.deptvalue,
    emp.subdeptvalue,
    emp.subdeptname,
    emp.clientname,
    emp.orgname,
    emp.designation,
    lp.hr_emplev_posting_id,
    lp.startdate AS validfrom,
    lp.enddate AS validto,
    lt.hr_levtypes_id,
    lt.value AS alias,
    lt.description,
    lt.isbalanced,
    lt.ischkbal,
    lt.isdeducted,
    lt.leaveunit AS unit,
    lt.attbalwd,
    lt.att_levtype_id,
    lt.maxleaves,
    lp.c_year_id,
        CASE
            WHEN lt.attbalwd = 'Y'::bpchar THEN 0.5::double precision
            ELSE date_part('day'::text, lp.enddate - lp.startdate) + 1::double precision
        END AS duration,
    ( SELECT ('Year <b> '::text || c_year.fiscalyear::text) || '</b>'::text
           FROM c_year
          WHERE c_year.c_year_id = lp.c_year_id) AS year,
    lt.name AS leavedesc,
    emp.hr_emplocation_id,
    lp.description AS attdescription,
    lt.is_adjusted,
    lt.adjust_against
   FROM xxhr_employee_v emp,
    hr_emplev_posting lp,
    hr_levtypes lt
  WHERE emp.c_bpartner_id = lp.c_bpartner_id AND emp.ad_client_id = lp.ad_client_id AND lp.hr_levtypes_id = lt.hr_levtypes_id;

ALTER TABLE adempiere.xx_emp_leaves_v
    OWNER TO adempiere;

