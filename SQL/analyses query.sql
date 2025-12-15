-----ANALYSES OVERVIEW: 
--1.Revenue concentration:Where is revenue coming from, and is it driven by deal value or volume
--2.Revenue Concentration (Top vs Rest) :Is revenue dependent on a few agents?
--3.Pipeline Health & Stage Distribution: Is this a sales execution issue or an upstream problem?
--4.Win Rate Stability Across Agents:Are low performers failing to close deals?

SELECT
    deal_stage,
    COUNT(*) AS deal_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS stage_distribution_pct
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY stage_distribution_pct DESC;





---- REVENUE CONCENTRATION

SELECT
    st.sales_agent,
    COUNT(*) FILTER (WHERE sp.deal_stage = 'Won') AS deals_closed,
    SUM(sp.close_value) AS total_revenue,
    ROUND(AVG(sp.close_value), 2) AS avg_deal_size,
    ROUND(
        COUNT(*) FILTER (WHERE sp.deal_stage = 'Won')::numeric /
        NULLIF(COUNT(*) FILTER (WHERE sp.deal_stage IN ('Won','Lost')), 0) * 100,
        2
    ) AS win_rate_pct
FROM sales_pipeline sp
JOIN sales_teams st
    ON sp.sales_agent = st.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY st.sales_agent
ORDER BY total_revenue DESC;



----Revenue Concentration (Top vs Rest) :Is revenue dependent on a few agents?

SELECT
    SUM(CASE WHEN rank <= 5 THEN total_revenue ELSE 0 END) AS top_5_revenue,
    SUM(total_revenue) AS total_revenue,
    ROUND(
        SUM(CASE WHEN rank <= 5 THEN total_revenue ELSE 0 END)::numeric /
        SUM(total_revenue) * 100,
        2
    ) AS top_5_revenue_pct
FROM (
    SELECT
        st.sales_agent,
        SUM(sp.close_value) AS total_revenue,
        RANK() OVER (ORDER BY SUM(sp.close_value) DESC) AS rank
    FROM sales_pipeline sp
    JOIN sales_teams st
        ON sp.sales_agent = st.sales_agent
    WHERE sp.deal_stage = 'Won'
    GROUP BY st.sales_agent
) t;


-----Pipeline Health & Stage Distribution: Is this a sales execution issue or an upstream problem?

SELECT
    deal_stage,
    COUNT(*) AS deal_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS stage_distribution_pct
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY stage_distribution_pct DESC;


----Win Rate Stability Across Agents:Are low performers failing to close deals?

SELECT
    st.sales_agent,
    ROUND(
        COUNT(*) FILTER (WHERE sp.deal_stage = 'Won')::numeric /
        NULLIF(COUNT(*) FILTER (WHERE sp.deal_stage IN ('Won','Lost')), 0) * 100,
        2
    ) AS win_rate_pct
FROM sales_pipeline sp
JOIN sales_teams st
    ON sp.sales_agent = st.sales_agent
GROUP BY st.sales_agent
ORDER BY win_rate_pct DESC;