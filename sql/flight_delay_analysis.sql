/*
============================================================
FLIGHT DELAY DIAGNOSTIC & CASCADE ANALYSIS
Dataset: December 2015 U.S. Flight Operations
Database: SQLite
============================================================

Primary definitions:
- Operated flight = CANCELLED = 0 AND DIVERTED = 0
- Delayed flight = ARRIVAL_DELAY > 15 minutes
- Delay rate = delayed operated flights / operated flights
- Potential cascade = current flight delayed AND previous flight
  delayed, with scheduled flights <= 4 hours apart
============================================================
*/


/* ==========================================================
   1. OVERALL FLIGHT PERFORMANCE
   ========================================================== */

SELECT
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0;


/* ==========================================================
   2. AVERAGE ARRIVAL DELAY
   ========================================================== */

SELECT
    ROUND(AVG(ARRIVAL_DELAY), 2) AS average_arrival_delay_minutes
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0;


/* ==========================================================
   3. AIRLINE DELAY PERFORMANCE
   ========================================================== */

SELECT
    AIRLINE,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent,
    ROUND(AVG(ARRIVAL_DELAY), 2)
        AS average_arrival_delay_minutes
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY AIRLINE
ORDER BY delay_rate_percent DESC;


/* ==========================================================
   4. AVERAGE DELAY WHEN A FLIGHT IS DELAYED
   ========================================================== */

SELECT
    AIRLINE,
    COUNT(*) AS delayed_flights,
    ROUND(AVG(ARRIVAL_DELAY), 2)
        AS average_delayed_arrival_minutes,
    ROUND(
        (
            SELECT AVG(f2.ARRIVAL_DELAY)
            FROM flights f2
            WHERE f2.AIRLINE = flights.AIRLINE
              AND f2.IS_DELAYED = 1
              AND f2.CANCELLED = 0
              AND f2.DIVERTED = 0
        ),
        2
    ) AS avg_delay_when_delayed
FROM flights
WHERE IS_DELAYED = 1
  AND CANCELLED = 0
  AND DIVERTED = 0
GROUP BY AIRLINE
ORDER BY avg_delay_when_delayed DESC;


/* ==========================================================
   5. DELAY CAUSE — TOTAL MINUTES
   ========================================================== */

SELECT
    ROUND(SUM(AIR_SYSTEM_DELAY), 0) AS air_system_delay_minutes,
    ROUND(SUM(SECURITY_DELAY), 0) AS security_delay_minutes,
    ROUND(SUM(AIRLINE_DELAY), 0) AS airline_delay_minutes,
    ROUND(SUM(LATE_AIRCRAFT_DELAY), 0)
        AS late_aircraft_delay_minutes,
    ROUND(SUM(WEATHER_DELAY), 0) AS weather_delay_minutes
FROM flights
WHERE IS_DELAYED = 1
  AND CANCELLED = 0
  AND DIVERTED = 0;


/* ==========================================================
   6. DELAY CAUSE — AFFECTED FLIGHTS
   ========================================================== */

SELECT
    SUM(CASE WHEN AIRLINE_DELAY > 0 THEN 1 ELSE 0 END)
        AS airline_affected_flights,

    SUM(CASE WHEN LATE_AIRCRAFT_DELAY > 0 THEN 1 ELSE 0 END)
        AS late_aircraft_affected_flights,

    SUM(CASE WHEN AIR_SYSTEM_DELAY > 0 THEN 1 ELSE 0 END)
        AS air_system_affected_flights,

    SUM(CASE WHEN WEATHER_DELAY > 0 THEN 1 ELSE 0 END)
        AS weather_affected_flights,

    SUM(CASE WHEN SECURITY_DELAY > 0 THEN 1 ELSE 0 END)
        AS security_affected_flights

FROM flights
WHERE IS_DELAYED = 1
  AND CANCELLED = 0
  AND DIVERTED = 0;


/* ==========================================================
   7. DELAY RATE BY DEPARTURE HOUR
   ========================================================== */

SELECT
    DEP_HOUR,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY DEP_HOUR
ORDER BY DEP_HOUR;


/* ==========================================================
   8. DELAY RATE BY DAY OF WEEK
   ========================================================== */

SELECT
    DAY_OF_WEEK,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY DAY_OF_WEEK
ORDER BY DAY_OF_WEEK;


/* ==========================================================
   9. AIRPORT DELAY PERFORMANCE
   ========================================================== */

SELECT
    ORIGIN_AIRPORT,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY ORIGIN_AIRPORT
HAVING COUNT(*) >= 500
ORDER BY delay_rate_percent DESC;


/* ==========================================================
   10. TOP 15 AIRPORTS BY DELAY RATE
   Minimum volume: 500 operated flights
   ========================================================== */

SELECT
    ORIGIN_AIRPORT,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY ORIGIN_AIRPORT
HAVING COUNT(*) >= 500
ORDER BY delay_rate_percent DESC
LIMIT 15;


/* ==========================================================
   11. AIRPORT VOLUME VS DELAY RATE
   ========================================================== */

SELECT
    ORIGIN_AIRPORT,
    COUNT(*) AS operated_flights,
    SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        AS delayed_flights,
    ROUND(
        100.0 * SUM(CASE WHEN IS_DELAYED = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS delay_rate_percent
FROM flights
WHERE CANCELLED = 0
  AND DIVERTED = 0
GROUP BY ORIGIN_AIRPORT
ORDER BY operated_flights DESC;


/* ==========================================================
   12. POTENTIAL CASCADE ANALYSIS
   ==========================================================

   Definition:
   - Current flight is delayed (>15 min)
   - Previous flight operated by same aircraft was delayed
   - Scheduled departure gap <= 4 hours

   This is an association/screening metric,
   not a causal estimate.
   ========================================================== */

WITH flight_sequence AS (
    SELECT
        TAIL_NUMBER,
        DAY,
        SCHEDULED_DEPARTURE,
        ARRIVAL_DELAY,
        IS_DELAYED,

        LAG(ARRIVAL_DELAY) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_ARRIVAL_DELAY,

        LAG(DAY) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_DAY,

        LAG(SCHEDULED_DEPARTURE) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_SCHEDULED_DEPARTURE

    FROM flights

    WHERE CANCELLED = 0
      AND DIVERTED = 0
),

with_gap AS (
    SELECT
        *,
        (
            (DAY - PREV_DAY) * 24
            +
            (
                (SCHEDULED_DEPARTURE / 100) * 60
                + (SCHEDULED_DEPARTURE % 100)
                -
                (
                    (PREV_SCHEDULED_DEPARTURE / 100) * 60
                    + (PREV_SCHEDULED_DEPARTURE % 100)
                )
            ) / 60.0
        ) AS scheduled_gap_hours

    FROM flight_sequence

    WHERE PREV_DAY IS NOT NULL
),

cascade_count AS (
    SELECT
        SUM(
            CASE
                WHEN IS_DELAYED = 1
                 AND PREV_ARRIVAL_DELAY > 15
                 AND scheduled_gap_hours <= 4
                THEN 1
                ELSE 0
            END
        ) AS potential_cascade_flights
    FROM with_gap
)

SELECT
    (
        SELECT COUNT(*)
        FROM flights
        WHERE IS_DELAYED = 1
    ) AS delayed_flights,

    potential_cascade_flights,

    ROUND(
        100.0 * potential_cascade_flights /
        (
            SELECT COUNT(*)
            FROM flights
            WHERE IS_DELAYED = 1
        ),
        2
    ) AS potential_cascade_rate_percent

FROM cascade_count;


/* ==========================================================
   13. CASCADE RATE BY PREVIOUS FLIGHT STATUS
   ========================================================== */

WITH flight_sequence AS (
    SELECT
        TAIL_NUMBER,
        DAY,
        SCHEDULED_DEPARTURE,
        IS_DELAYED,

        LAG(IS_DELAYED) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_IS_DELAYED,

        LAG(DAY) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_DAY,

        LAG(SCHEDULED_DEPARTURE) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_SCHEDULED_DEPARTURE

    FROM flights

    WHERE CANCELLED = 0
      AND DIVERTED = 0
),

with_gap AS (
    SELECT
        *,
        (
            (DAY - PREV_DAY) * 24
            +
            (
                (SCHEDULED_DEPARTURE / 100) * 60
                + (SCHEDULED_DEPARTURE % 100)
                -
                (
                    (PREV_SCHEDULED_DEPARTURE / 100) * 60
                    + (PREV_SCHEDULED_DEPARTURE % 100)
                )
            ) / 60.0
        ) AS scheduled_gap_hours

    FROM flight_sequence

    WHERE PREV_DAY IS NOT NULL
)

SELECT
    CASE
        WHEN PREV_IS_DELAYED = 1
            THEN 'Previous flight delayed'
        ELSE 'Previous flight not delayed'
    END AS previous_flight_status,

    COUNT(*) AS current_flights,

    SUM(
        CASE
            WHEN IS_DELAYED = 1 THEN 1
            ELSE 0
        END
    ) AS current_delayed_flights,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN IS_DELAYED = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS current_delay_rate_percent

FROM with_gap

WHERE scheduled_gap_hours <= 4
  AND PREV_IS_DELAYED IS NOT NULL

GROUP BY PREV_IS_DELAYED
ORDER BY PREV_IS_DELAYED DESC;


/* ==========================================================
   14. PREVIOUS FLIGHT DELAY SEVERITY
   ========================================================== */

WITH flight_sequence AS (
    SELECT
        TAIL_NUMBER,
        DAY,
        SCHEDULED_DEPARTURE,
        ARRIVAL_DELAY,
        IS_DELAYED,

        LAG(ARRIVAL_DELAY) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_ARRIVAL_DELAY,

        LAG(DAY) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_DAY,

        LAG(SCHEDULED_DEPARTURE) OVER (
            PARTITION BY TAIL_NUMBER
            ORDER BY DAY, SCHEDULED_DEPARTURE
        ) AS PREV_SCHEDULED_DEPARTURE

    FROM flights

    WHERE CANCELLED = 0
      AND DIVERTED = 0
),

with_gap AS (
    SELECT
        *,
        (
            (DAY - PREV_DAY) * 24
            +
            (
                (SCHEDULED_DEPARTURE / 100) * 60
                + (SCHEDULED_DEPARTURE % 100)
                -
                (
                    (PREV_SCHEDULED_DEPARTURE / 100) * 60
                    + (PREV_SCHEDULED_DEPARTURE % 100)
                )
            ) / 60.0
        ) AS scheduled_gap_hours

    FROM flight_sequence

    WHERE PREV_DAY IS NOT NULL
)

SELECT
    CASE
        WHEN PREV_ARRIVAL_DELAY BETWEEN 16 AND 30
            THEN '16–30 min'
        WHEN PREV_ARRIVAL_DELAY BETWEEN 31 AND 60
            THEN '31–60 min'
        WHEN PREV_ARRIVAL_DELAY BETWEEN 61 AND 120
            THEN '61–120 min'
        WHEN PREV_ARRIVAL_DELAY > 120
            THEN '120+ min'
    END AS previous_delay_bucket,

    COUNT(*) AS flights,

    SUM(
        CASE
            WHEN IS_DELAYED = 1 THEN 1
            ELSE 0
        END
    ) AS current_delayed_flights,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN IS_DELAYED = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS current_delay_rate_percent

FROM with_gap

WHERE PREV_ARRIVAL_DELAY > 15
  AND scheduled_gap_hours <= 4

GROUP BY previous_delay_bucket

ORDER BY
    CASE previous_delay_bucket
        WHEN '16–30 min' THEN 1
        WHEN '31–60 min' THEN 2
        WHEN '61–120 min' THEN 3
        WHEN '120+ min' THEN 4
    END;


/* ==========================================================
   END OF ANALYSIS
   ========================================================== */