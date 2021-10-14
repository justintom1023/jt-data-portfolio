-- Number of Reigns

SELECT champion, COUNT(reign) AS number_of_reigns
FROM iwgp_heavyweight_champions
WHERE champ_no IS NOT NULL
GROUP BY champion
ORDER BY 2 DESC


-- Combined Defenses

SELECT champion, SUM(defenses) AS combined_defenses
FROM iwgp_heavyweight_champions
WHERE champion != 'Unified'
AND champion != 'Vacated'
GROUP BY champion
ORDER BY 2 DESC


-- Combined Days

SELECT champion, SUM(days) AS combined_days
FROM iwgp_heavyweight_champions
WHERE champion != 'Unified'
AND champion != 'Vacated'
GROUP BY champion
ORDER BY 2 DESC


-- Number of Championship Changes by Location

SELECT location, COUNT(location) AS championship_changes
FROM iwgp_heavyweight_champions
WHERE champion != 'Unified'
AND champion != 'Vacated'
GROUP BY location
ORDER BY 2 DESC


-- Number of Defenses by Reign
SELECT champ_no, champion, SUM(defenses) AS number_of_defenses
FROM iwgp_heavyweight_champions
WHERE champion != 'Unified'
AND champion != 'Vacated'
GROUP BY champ_no, champion
ORDER BY 3 DESC
