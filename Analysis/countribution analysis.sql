

---Created by: Omid Sarafmanesh
--------------------------------------------
WITH CityInteractions AS (
  SELECT 
    headers::json->>'city' AS city,
    headers::json->>'country' AS country,
    event_time::date AS event_date,
    SUM(num_hits) AS interaction_count
  FROM 
    aggregated_web_traffic
  GROUP BY 
    headers::json->>'city',
    headers::json->>'country',
    event_time::date
),
CountryInteractions AS (
  SELECT 
    headers::json->>'country' AS country,
    event_time::date AS event_date,
    SUM(SUM(num_hits)) OVER (PARTITION BY headers::json->>'country', event_time::date) AS interaction_count
  FROM 
    aggregated_web_traffic
  GROUP BY 
    headers::json->>'country',
    event_time::date
),
GlobalContribution AS (
  SELECT 
    SUM(interaction_count) AS global_interaction_count
  FROM 
    CityInteractions
),
AggregatedInsights AS (
  SELECT
    ci.city,
    ci.event_date,
    json_build_object(
      'city', ci.city,
      'count', ci.interaction_count
    ) AS city_contribution,
    json_build_object(
      'country', ci.country,
      'total_count', c.interaction_count
    ) AS country_contribution,
    gc.global_interaction_count AS global_contribution,
    (ci.interaction_count::float / gc.global_interaction_count::float) * 100 AS percentage_contribution,
    LAG(ci.interaction_count) OVER (PARTITION BY ci.city ORDER BY ci.event_date) AS previous_day_contribution,
    LEAD(ci.interaction_count) OVER (PARTITION BY ci.city ORDER BY ci.event_date) AS next_day_contribution
  FROM 
    CityInteractions ci
  JOIN 
    CountryInteractions c ON ci.event_date = c.event_date AND ci.country = c.country
  CROSS JOIN 
    GlobalContribution gc
  ORDER BY 
    ci.interaction_count DESC
  LIMIT 10
),
FinalForecast AS (
  SELECT
    *,
    (COALESCE(next_day_contribution, 0) - COALESCE(previous_day_contribution, 0)) AS forecasted_change
  FROM 
    AggregatedInsights
)
SELECT
  city_contribution,
  country_contribution,
  global_contribution,
  percentage_contribution,
  previous_day_contribution,
  next_day_contribution,
  forecasted_change
FROM 
  FinalForecast;
