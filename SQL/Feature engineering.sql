

-- 1. AGENT PERFORMANCE & SEGMENTATION
--------------------------------------------------
WITH agent_REVENUE AS(
   SELECT sales_agent,
   SUM(close_value) AS total_sales,
   COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END) AS deals_won,
   COUNT(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 END) AS closed_deals,
   AVG(close_value) AS avg_deal_size,
   NTILE(5) OVER(ORDER BY SUM(close_value) DESC) AS segment
   FROM sales_pipeline_revenue
   GROUP BY sales_agent
)

   SELECT sales_agent,
        total_sales,
		deals_won,
		total_sales/closed_deals AS revenue_per_deal,
		ROUND((total_sales/SUM(total_sales) OVER())*100,2) AS employee_Revenue_percentage,
		ROUND(avg_deal_size,2) AS avg_revenue_per_deal,
		ROUND(deals_won::numeric / NULLIF(closed_deals, 0) * 100, 2) AS win_rate_pct,
		CASE WHEN segment=1 THEN 'Top '
		     WHEN segment in(2,3,4) THEN 'Normal '
			 ELSE 'Low '
		END AS performance
		FROM agent_REVENUE
;

-- 2. SALES PIPELINE / FUNNEL DISTRIBUTION
--------------------------------------------------
SELECT
    deal_stage,
    COUNT(*) AS deal_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS stage_distribution_pct
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY deal_count DESC;


-- 3. OVERALL WIN RATE
--------------------------------------------------
SELECT
    ROUND(
        COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END)::numeric /
        NULLIF(COUNT(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 END), 0)
        * 100,
        2
    ) AS overall_win_rate_pct
FROM sales_pipeline;


-- 4. PRODUCT PERFORMANCE
--------------------------------------------------
SELECT
    product,
    COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END) AS deals_won,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value END) AS total_revenue,
    ROUND(AVG(CASE WHEN deal_stage = 'Won' THEN close_value END), 2) AS avg_deal_size,
    ROUND(
        COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END)::numeric /
        NULLIF(COUNT(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 END), 0)
        * 100,
        2
    ) AS product_win_rate_pct
FROM sales_pipeline
GROUP BY product
ORDER BY total_revenue DESC;


-- 5. ICP / SECTOR ANALYSIS
--------------------------------------------------
WITH deal_account AS (
    SELECT
        p.deal_stage,
        p.close_value,
        a.sector,
        a.employees,
        a.revenue AS account_revenue
    FROM sales_pipeline p
    JOIN accounts a
        ON p.account = a.account
)
SELECT
    sector,
    COUNT(*) AS total_deals,
    ROUND(
        COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END)::numeric /
        NULLIF(COUNT(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 END), 0)
        * 100,
        2
    ) AS sector_win_rate_pct,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value END) AS total_revenue,
    CASE
        WHEN employees < 500 THEN 'Small (<500)'
        WHEN employees BETWEEN 500 AND 2000 THEN 'Mid (500–2k)'
        ELSE 'Large (>2k)'
    END AS company_size,
    CASE
        WHEN account_revenue < 500 THEN 'Low Rev (<500M)'
        WHEN account_revenue BETWEEN 500 AND 2500 THEN 'Mid Rev (500M–2.5B)'
        ELSE 'High Rev (>2.5B)'
    END AS revenue_band
FROM deal_account
GROUP BY sector, company_size, revenue_band
ORDER BY total_revenue DESC;

