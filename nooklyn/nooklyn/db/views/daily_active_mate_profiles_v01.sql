WITH mate_post_days AS (
    SELECT generate_series(date_range.start_date :: TIMESTAMP, date_range.end_date :: TIMESTAMP,
                           '1 day' :: INTERVAL) :: DATE AS date
    FROM
      (
        SELECT
          min(created_at) :: DATE AS start_date,
          CURRENT_DATE            AS end_date
        FROM mate_posts
      ) date_range
)
SELECT
  row_number() OVER (ORDER BY mate_post_days.date) AS id,
  mate_post_days.date,
  COUNT(1) AS amount
FROM mate_post_days
  LEFT OUTER JOIN mate_posts ON mate_post_days.date BETWEEN mate_posts.created_at AND mate_posts."when"
GROUP BY mate_post_days.date
ORDER BY mate_post_days.date
