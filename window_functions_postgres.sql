SELECT * FROM clickstream;

SELECT * FROM clickstream
WHERE eventid = 'f3ee0c19-a8f9-4153-b34e-b631ba383fad';


-- row number of event id partitioned by user
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		ROW_NUMBER() OVER (
			PARTITION BY userid
			ORDER BY userid, datetimecreated DESC
		) AS eventorder
FROM clickstream;


-- 
SELECT	userid,
		COUNT(eventid) as eventcount
FROM clickstream
GROUP BY userid


-- row number of event id partitioned by user
-- partition by returns results to row level (non aggregation)
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		ROW_NUMBER() OVER (
			PARTITION BY userid,
						 sessionid
			ORDER BY userid, datetimecreated DESC
		) AS eventorder
FROM clickstream;

-- 
SELECT	userid,
		sessionid,
		COUNT(eventid) as eventcount
FROM clickstream
GROUP BY userid, sessionid
ORDER BY userid, sessionid;


-- cumsum of event id partitioned by user
-- partition by returns results to row level (non aggregation)
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		CUME_DIST() OVER (
			PARTITION BY userid
			ORDER BY userid, datetimecreated DESC
		) AS eventorder
FROM clickstream;


-- first_value of event id partitioned by user
-- partition by returns results to row level (non aggregation)
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		first_value(eventid) OVER (
			PARTITION BY userid
			ORDER BY userid, datetimecreated DESC
		) AS first_event
FROM clickstream;


-- lag of event id partitioned by user 
-- or gives the previous value of the col in that partition
-- partition by returns results to row level (non aggregation)
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		lag(eventid) OVER (
			PARTITION BY userid
			ORDER BY userid, datetimecreated DESC
		) AS first_event
FROM clickstream;


-- nth_value of event id partitioned by user 
-- or gives the nth value of the col in that partition ll|
-- partition by returns results to row level (non aggregation)
SELECT	eventid,
		userid,
		sessionid,
		actiontype,
		datetimecreated,
		nth_value(eventid, 2) OVER (
			PARTITION BY userid
			ORDER BY userid, datetimecreated DESC
		) AS first_event,
		COUNT(eventid) OVER (
			PARTITION BY userid
		) AS event_max_count
FROM clickstream;


-- lead and lag
-- These can be used to perform calculations based on data from other rows.
-- Lead and Lag are used to access data from rows after or before the
-- current row respectively. The rows can be ordered using the order by clause.
select eventId,
    userId,
    sessionId,
    actionType,
    datetimeCreated,
    LEAD(datetimeCreated, 1) OVER(
        PARTITION BY userId,
        sessionId
        ORDER BY datetimeCreated
    ) as nextEventTime,
    LAG(datetimeCreated, 1) OVER(
        PARTITION BY userId,
        sessionId
        ORDER BY datetimeCreated
    ) as prevEventTime
from clickstream;


-- We can use window functions without a PARTITION BY
-- clause to simulate a rolling window over all the rows
-- find the number of buy events within the last 3 events across
-- all users exclusive of the current even
select eventId,
    userId,
    sessionId,
    actionType,
    datetimeCreated,
    SUM(
        CASE
            WHEN actionType = 'buy' THEN 1
            ELSE 0
        END
    ) OVER(
        ORDER BY datetimeCreated DESC ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ) as num_purchases
from clickstream;
-- the window starts from the 5 PRECEDING rows and stops before
-- the current row, which is the 1 PRECEDING row.


-- query to check if one of the current, previous, or next events was a buy event.
select eventId,
    userId,
    sessionId,
    actionType,
    datetimeCreated,
    MAX(
        CASE
            WHEN actionType = 'buy' THEN 1
            ELSE 0
        END
    ) OVER(
        ORDER BY datetimeCreated DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) as neighborBuy
from clickstream;



-- watchput for performance and complexity
-- with window function
EXPLAIN ANALYZE
select *
from (
        select userId,
            sessionId,
            datetimeCreated,
            ROW_NUMBER() OVER(
                PARTITION BY userId,
                sessionId
                ORDER BY datetimeCreated DESC
            ) as eventOrder
        from clickstream
    ) as t
where t.eventOrder = 1;

-- with non-window aggregate
EXPLAIN ANALYZE
select userId,
    sessionId,
    max(datetimeCreated) as datetimeCreated
from clickstream
group by userId,
    sessionId;