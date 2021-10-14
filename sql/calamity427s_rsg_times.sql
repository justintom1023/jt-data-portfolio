-- Time by Minutes (W/O Outliers)

SELECT run_number,
       ROUND(SUM(DATEDIFF('second', started_, ended) / 60.0), 2) AS minutes_
FROM calamity427s_rsg_times
GROUP BY run_number
HAVING ROUND(SUM(DATEDIFF('second', started_, ended) / 60.0), 2)
       BETWEEN 0.33 AND 50.60
ORDER BY 2 DESC


-- Time by Seconds (W/O Outliers)

SELECT run_number,
       SUM(DATEDIFF('second', started_, ended)) AS seconds
FROM calamity427s_rsg_times
GROUP BY run_number
HAVING SUM(DATEDIFF('second', started_, ended)) BETWEEN 20 AND 3036
ORDER BY 2 DESC


-- Average Time of Every 1,000 Runs by Minutes (W/ Outliers)

SELECT (r - 1) / 100 AS group_id, ROUND(AVG(seconds), 2) -- integer division
FROM
(
	SELECT RANK() OVER (ORDER BY run_no) AS r,
		   DATEDIFF('second', started_, ended) / 60.0 AS seconds
	FROM calamity427s_rsg_times
) a
GROUP BY 1
ORDER BY 2 DESC
