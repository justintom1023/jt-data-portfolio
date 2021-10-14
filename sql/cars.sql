-- Average Miles Broken by Fuel and Transmission

SELECT season, SUM(avg_mileage) AS sum_avg_mileage
FROM
(
    SELECT fuel_type, transmission, ROUND(AVG(mileage)) AS avg_mileage
    FROM cars
    WHERE transmission = 'auto'
    GROUP BY fuel_type, transmission

    UNION ALL

    SELECT fuel_type, transmission, ROUND(AVG(mileage)) AS avg_mileage
    FROM cars
    WHERE transmission = 'man'
    GROUP BY fuel_type, transmission
) a
GROUP BY season


-- Average Miles by Manufacturer Sliced by Fuel Type

SELECT maker, SUM(avg_mileage) AS sum_avg_mileage
FROM
(
	SELECT maker, fuel_type, AVG(mileage) AS avg_mileage
	FROM cars
	WHERE maker IN
	(
		SELECT maker
		FROM cars
		GROUP BY maker
		ORDER BY AVG(mileage) DESC
		LIMIT 10 -- top 10
	)
	GROUP BY maker, fuel_type
) a
GROUP BY maker
ORDER BY maker -- alphabetical order


-- Manufacturer Broken by Fuel and Transmission

SELECT maker, fuel_type, transmission, COUNT(*)
FROM cars
GROUP BY maker, fuel_type, transmission


-- Top 5 Manufacturers

SELECT maker, model, total_cars
FROM
(
	SELECT maker, model,
           COUNT(*) AS total_cars,
           DENSE_RANK() OVER(PARTITION BY maker ORDER BY COUNT(*) DESC) AS dr
	FROM cars
	WHERE maker IN
	(
		SELECT maker
		FROM cars
		GROUP BY maker
		ORDER BY COUNT(*) DESC
		LIMIT 5
	)
	GROUP BY maker, model
) a
WHERE dr BETWEEN 1 AND 5


-- Top 10 Vehicles Quantity

SELECT maker, COUNT(*) AS total_cars
FROM cars
WHERE maker IS NOT NULL
GROUP BY maker
ORDER BY COUNT(*) DESC
LIMIT 10
