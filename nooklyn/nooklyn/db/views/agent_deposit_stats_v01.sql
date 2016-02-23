WITH normalized_deposits AS (
  SELECT
    sales_agent_id AS agent_id,
    id             AS deposit_id,
    "when"         AS move_in_date,
    CASE WHEN other_sales_agent_id IS NULL
      THEN FALSE
    ELSE TRUE END  AS is_split,
    CASE deposit_status_id
    WHEN 3
      THEN 'Completed'
    WHEN 4
      THEN 'Cancelled'
    ELSE
      'Active'
    END            AS status
  FROM deposits
  UNION ALL
  SELECT
    other_sales_agent_id AS agent_id,
    id                   AS deposit_id,
    "when"               AS move_in_date,
    CASE WHEN other_sales_agent_id IS NULL
      THEN FALSE
    ELSE TRUE END        AS is_split,
    CASE deposit_status_id
    WHEN 3
      THEN 'Completed'
    WHEN 4
      THEN 'Cancelled'
    ELSE
      'Active'
    END                  AS status
  FROM deposits
  WHERE other_sales_agent_id IS NOT NULL
)
SELECT
  agent_id,
  EXTRACT(YEAR FROM move_in_date) :: INTEGER  AS year,
  EXTRACT(MONTH FROM move_in_date) :: INTEGER AS month,
  COUNT(1)
    FILTER (WHERE status = 'Completed')       AS completed_deposits,
  COUNT(1)
    FILTER (WHERE status = 'Active')          AS active_deposits,
  COUNT(1)
    FILTER (WHERE status = 'Cancelled')       AS cancelled_deposits
FROM normalized_deposits
GROUP BY 1, 2, 3
