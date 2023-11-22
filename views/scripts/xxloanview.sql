--liquibase formatted sql

--changeset  usama:view_36 runOnChange:true stripeComments:false

-- View: adempiere.xxloanview

-- DROP VIEW adempiere.xxloanview;

CREATE OR REPLACE VIEW adempiere.xxloanview
 AS
 SELECT a.c_bpartner_id,
    a.c_doctypetarget_id,
    a.c_invoiceline_id,
    a.loanamount,
    a.loaninstall,
    a.datestarts,
    a.amtrecvd,
        CASE
            WHEN (a.loanamount - (a.amtrecvd + COALESCE(a.loanreverse, 0::numeric))) < a.loaninstall THEN a.loanamount - (a.amtrecvd + COALESCE(a.loanreverse, 0::numeric))
            ELSE a.loaninstall
        END AS loanded,
    a.loanreverse
   FROM ( SELECT m.c_bpartner_id,
            m.c_doctypetarget_id,
            d.c_invoiceline_id,
            d.priceactual AS loanamount,
            d.loaninstall,
            d.datestarts,
            COALESCE(( SELECT sum(hr_salary_entry.amount) AS sum
                   FROM hr_salary_entry
                  WHERE hr_salary_entry.c_bpartner_id = m.c_bpartner_id AND hr_salary_entry.hr_concept_id = 1000022::numeric AND hr_salary_entry.c_invoiceline_id = d.c_invoiceline_id), 0::numeric) AS amtrecvd,
            COALESCE(( SELECT sum(c_invoiceline.priceactual * '-1'::integer::numeric) AS sum
                   FROM c_invoiceline
                  WHERE (c_invoiceline.c_invoice_id IN ( SELECT c_invoice.c_invoice_id
                           FROM c_invoice
                          WHERE c_invoice.c_doctype_id = 1000048::numeric AND c_invoice.docstatus = 'CO'::bpchar AND c_invoice.c_bpartner_id = m.c_bpartner_id)) AND c_invoiceline.priceactual < 0::numeric AND c_invoiceline.c_invoiceliner_id = d.c_invoiceline_id), 0::numeric) AS loanreverse
           FROM c_invoice m,
            c_invoiceline d
          WHERE m.docstatus = 'CO'::bpchar AND m.c_invoice_id = d.c_invoice_id AND m.c_doctypetarget_id = 1000048::numeric) a
  WHERE
        CASE
            WHEN (a.loanamount - (a.amtrecvd + COALESCE(a.loanreverse, 0::numeric))) < a.loaninstall THEN a.loanamount - (a.amtrecvd + COALESCE(a.loanreverse, 0::numeric))
            WHEN (a.loanamount - a.amtrecvd) > a.loaninstall THEN a.loaninstall
            WHEN a.loanamount = a.loanamount THEN a.loaninstall
            ELSE NULL::numeric
        END > 0::numeric;

ALTER TABLE adempiere.xxloanview
    OWNER TO adempiere;

