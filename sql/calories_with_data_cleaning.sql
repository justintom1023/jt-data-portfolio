-- Data Cleaning

SELECT *
FROM calories


-- per100grams contains either 100g or 100ml with no NULL
-- values, so changing the values to integers should be
-- simple. We also know that 100g = 100m.

SELECT DISTINCT per100grams
FROM calories

SELECT *
FROM calories
WHERE per100grams IS NULL

SELECT per100grams, 100
FROM calories

ALTER TABLE calories
ADD per_100_grams INT

UPDATE calories
SET per_100_grams = 100


-- cals_per100grams is next! This one is different than
-- the per100grams column because there are many unique
-- records and we have to split the numbers and words apart.

SELECT cals_per100grams
FROM calories
ORDER BY 1 DESC

-- We need to subtract 1 from the CHARINDEX function or else
-- the whitespace after the number will be included.

SELECT cals_per100grams,
	   CAST(SUBSTRING(cals_per100grams, 1, CHARINDEX(' ', cals_per100grams) - 1) AS INT)
FROM calories
ORDER BY 2 DESC

ALTER TABLE calories
ADD cals_per_100_grams INT

UPDATE calories
SET cals_per_100_grams = CAST(SUBSTRING(cals_per100grams, 1,
							  CHARINDEX(' ', cals_per100grams) - 1) AS INT)


-- kj_per100grams is very similar to cals_per100grams!

-- We need to subtract 1 from the CHARINDEX function or else
-- the whitespace after the number will be included.

SELECT KJ_per100grams,
	   CAST(SUBSTRING(KJ_per100grams, 1, CHARINDEX(' ', KJ_per100grams) - 1) AS INT)
FROM calories
ORDER BY 2 DESC

ALTER TABLE calories
ADD kj_per_100_grams INT

UPDATE calories
SET kj_per_100_grams = CAST(SUBSTRING(KJ_per100grams, 1,
					   CHARINDEX(' ', KJ_per100grams) - 1) AS INT)


-- The data cleaning is complete. Let's write some queries!

SELECT fooditem, foodcategory, cals_per_100_grams
FROM calories
ORDER BY cals_per_100_grams DESC

-- It seems that oil has a lot of calories compared
-- to other categories. Let's filter out the outliers.

SELECT fooditem, foodcategory, cals_per_100_grams
FROM calories
WHERE LOWER(foodcategory) NOT LIKE '%oil%'
AND LOWER(fooditem) NOT LIKE '%oil%'
ORDER BY cals_per_100_grams DESC


-- AGGREGATIONS & CORRELATED SUBQUERIES

-- Average Food Categorical Calories

SELECT foodcategory, AVG(kj_per_100_grams) AS avg_kj_per_100_gram
FROM calories
GROUP BY foodcategory
ORDER BY 2 DESC


-- Items That Have Higher Calories Above the Average Categorical Calories

SELECT fooditem, cals_per_100_grams
FROM calories c1
WHERE cals_per_100_grams > (SELECT AVG(cals_per_100_grams) FROM calories c2
						    WHERE c1.foodcategory = c2.foodcategory)


-- Categories That Have More Than 50 Items

SELECT foodcategory
FROM calories
GROUP BY foodcategory
HAVING COUNT(*) > 50
ORDER BY foodcategory

-- This involves a subquery that produces the same result as
-- the above subquery. However, it is important to note that
-- subqueries are slower because the WHERE condition depends
-- on values obtained from the rows of the outer query which
-- will execute once for each row.

SELECT DISTINCT foodcategory
FROM calories c1
WHERE 50 < (SELECT COUNT(*) FROM calories c2
			WHERE c1.foodcategory = c2.foodcategory)
ORDER BY foodcategory


-- WINDOW FUNCTIONS

SELECT fooditem, foodcategory,
	   COUNT(*) OVER(PARTITION BY foodcategory) category_count
FROM calories
ORDER BY fooditem


-- Running Total of Calories

SELECT fooditem, foodcategory, cals_per_100_grams,
	SUM(cals_per_100_grams) OVER(PARTITION BY foodcategory
								 ORDER BY fooditem) AS running_total_of_calories
FROM calories


-- Categorical Rankings

SELECT fooditem, foodcategory, cals_per_100_grams,
	   DENSE_RANK() OVER(PARTITION BY foodcategory ORDER BY cals_per_100_grams DESC)
FROM calories


-- CASE STATEMENTS

-- Is this item a light snack or a meal?

SELECT fooditem, cals_per_100_grams,
	   CASE WHEN cals_per_100_grams < 300 THEN 'LIGHT SNACK'
			WHEN cals_per_100_grams BETWEEN 300 AND 800 THEN 'MEAL'
			ELSE 'CHEAT DAY' END AS type_of_item
FROM calories


SELECT fooditem, CASE WHEN DENSE_RANK() OVER(ORDER BY cals_per_100_grams DESC)
					  BETWEEN 1 AND 5 THEN 'SUPER CHEAT DAY'
					  ELSE 'CHEAT DAY' END AS type_of_cheat_day
FROM (
		SELECT fooditem, cals_per_100_grams,
		CASE WHEN cals_per_100_grams < 300 THEN 'LIGHT SNACK'
		     WHEN cals_per_100_grams BETWEEN 300 AND 800 THEN 'MEAL'
			 ELSE 'CHEAT DAY' END AS type_of_item
		FROM calories
	 ) a
WHERE type_of_item = 'CHEAT DAY'
