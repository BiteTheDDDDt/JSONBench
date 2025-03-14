------------------------------------------------------------------------------------------------------------------------
-- Q1 - Top event types
------------------------------------------------------------------------------------------------------------------------
SELECT
    data::commit::collection AS event,
    count(*) AS count
FROM
    bluesky
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q2 - Top event types together with unique users per event type
------------------------------------------------------------------------------------------------------------------------
SELECT
    data::commit::collection AS event,
    count(*) AS count,
    count(distinct data::did)
FROM
    bluesky
WHERE
    data::$kind = 'commit'
  AND data::commit::$operation = 'create'
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q3 - When do people use BlueSky
------------------------------------------------------------------------------------------------------------------------
SELECT
    data::commit::collection AS event,
    hour(from_unixtime(data::time_us/1000000)) AS hour_of_day,
    count(*) AS count
FROM
    bluesky
WHERE
    data::$kind = 'commit'
  AND data::commit::$operation = 'create'
  AND data::commit::$collection IN ('app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like')
GROUP BY event, hour_of_day
ORDER BY hour_of_day, event;

------------------------------------------------------------------------------------------------------------------------
-- Q4 - top 3 post veterans
------------------------------------------------------------------------------------------------------------------------
SELECT
    data::$did AS user_id,
    min(from_unixtime(data::time_us/1000000)) AS first_post_ts
FROM
    bluesky
WHERE
    data::kind = 'commit'
  AND data::commit::$operation = 'create'
  AND data::commit::$collection = 'app.bsky.feed.post'
GROUP BY user_id
ORDER BY first_post_ts ASC
LIMIT 3;

------------------------------------------------------------------------------------------------------------------------
-- Q5 - top 3 users with longest activity
------------------------------------------------------------------------------------------------------------------------
SELECT
    data::$did AS user_id,
    timestampdiff(microsecond, min(from_unixtime(data::time_us/1000000)), max(from_unixtime(data::time_us/1000000))) as activity_span
FROM
    bluesky
WHERE
    data::$kind = 'commit'
  AND data::commit::$operation= 'create'
  AND data::commit::$collection = 'app.bsky.feed.post'
GROUP BY user_id
ORDER BY activity_span DESC
LIMIT 3;
