-- Global Death Percentage

SELECT SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_deaths,
       SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Total Deaths per Continent

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY 2 DESC


-- Percent Population Infected per Country

SELECT location, population,
	   MAX(total_cases) AS highest_infection_count,
	   MAX(total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY 4 DESC


-- Percent Population Infected

SELECT location, population, date,
	   MAX(total_cases) AS highest_infection_count,
	   MAX(total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY 5 DESC


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	  SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location
	  ORDER BY d.location, d.date) AS running_total
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3
