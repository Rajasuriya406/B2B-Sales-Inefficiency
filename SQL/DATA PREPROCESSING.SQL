---DATA PREPROCESSING

--CHECKING FOR NULL VALUE IN ACCOUNTS TABLE

SELECT
    COUNT(*) FILTER (WHERE account IS NULL) AS account_nulls,
    COUNT(*) FILTER (WHERE sector IS NULL) AS sector_nulls,
    COUNT(*) FILTER (WHERE revenue IS NULL) AS revenue_nulls,
    COUNT(*) FILTER (WHERE employees IS NULL) AS employees_nulls
FROM accounts;

--CHECKING FOR NULL VALUE IN PRODUCT

--CHECKING FOR NULL VALUE IN SALES_TEAM

SELECT
    COUNT(*) FILTER (WHERE sales_agent IS NULL) AS sales_rep_nulls,
    COUNT(*) FILTER (WHERE manager IS NULL) AS manager_null,
    COUNT(*) FILTER (WHERE regional_office IS NULL) AS regional_null
FROM sales_team;


--CHECKING FOR NULL VALUE IN SALES_PIPELINE 

SELECT
    COUNT(*) FILTER (WHERE opportunity_id IS NULL) AS opportunity_id_nulls,
    COUNT(*) FILTER (WHERE account IS NULL) AS account_null,
    COUNT(*) FILTER (WHERE close_value IS NULL) AS close_value_null,
   COUNT(*) FILTER (WHERE product IS NULL) AS product_nulls,
    COUNT(*) FILTER (WHERE deal_stage IS NULL) AS deal_stage_nulls
FROM sales_pipeline;




---HANDLING NULL VALUES FOR SALES PIPELINE

CREATE TABLE sales_pipeline_revenue AS(
    SELECT * FROM sales_pipeline 
	WHERE close_value IS NOT NULL
);

