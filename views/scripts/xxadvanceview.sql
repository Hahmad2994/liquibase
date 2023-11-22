--liquibase formatted sql

--changeset  usama:view_32 runOnChange:true stripeComments:false

-- View: adempiere.xxadvanceview

-- DROP VIEW adempiere.xxadvanceview;

CREATE OR REPLACE VIEW adempiere.xxadvanceview
 AS
 SELECT a.c_bpartner_id,
    a.c_doctypetarget_id,
    a.c_invoiceline_id,
    a.loanamount,
    a.loaninstall,
    a.datestarts,
    a.amtrecvd,
        CASE
            WHEN (a.loanamount - a.amtrecvd) < a.loaninstall THEN a.loanamount - a.amtrecvd
            ELSE a.loaninstall
        END AS loanded
   FROM ( SELECT m.c_bpartner_id,
            m.c_doctypetarget_id,
            d.c_invoiceline_id,
            d.priceactual AS loanamount,
            d.loaninstall,
            d.datestarts,
            COALESCE(( SELECT sum(hr_salary_entry.amount) AS sum
                   FROM hr_salary_entry
                  WHERE hr_salary_entry.c_bpartner_id = m.c_bpartner_id AND hr_salary_entry.hr_concept_id = 1000021::numeric AND hr_salary_entry.c_invoiceline_id = d.c_invoiceline_id), 0::numeric) AS amtrecvd
           FROM c_invoice m,
            c_invoiceline d
          WHERE m.docstatus = 'CO'::bpchar AND m.c_invoice_id = d.c_invoice_id AND m.c_doctypetarget_id = 1000047::numeric) a
  WHERE
        CASE
            WHEN (a.loanamount - a.amtrecvd) < a.loaninstall THEN a.loanamount - a.amtrecvd
            WHEN (a.loanamount - a.amtrecvd) > a.loaninstall THEN a.loaninstall
            WHEN a.loanamount = a.loanamount THEN a.loaninstall
            ELSE NULL::numeric
        END > 0::numeric;

ALTER TABLE adempiere.xxadvanceview
    OWNER TO adempiere;

