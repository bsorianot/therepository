SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- SELECTING DATA I WILL BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2
-- CASES VS DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%united states%'
ORDER BY 1,2
-- TOTAL VASES VS POPULATION
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%united states%'
ORDER BY 1,2
-- HIGHEST INFECTION RATES PER COUNTRY
SELECT location, MAX (total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%united states%'
GROUP BY location, population
ORDER BY 3 DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX (CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM (new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM (CAST(new_deaths AS INT))/SUM(New_Cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATIONS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(CONVERT(BIGINT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinations AS vacs
ON deaths.location=vacs.location
AND deaths.date=vacs.date 
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

--USE CTE TO GET PERCENTAGE OF POPULATION VS VACCINES
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(CONVERT(BIGINT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinations AS vacs
ON deaths.location=vacs.location
AND deaths.date=vacs.date 
WHERE deaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--USE TEMP TABLE TO GET PERCENTAGE OF POPULATION VS VACCINES
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric
)
INSERT INTO #PercentPopVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(CONVERT(BIGINT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinations AS vacs
ON deaths.location=vacs.location
AND deaths.date=vacs.date 
WHERE deaths.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

--CREATING VIEW TO STORE DATA FOR TABLEAU
CREATE VIEW PercentPopVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(CONVERT(BIGINT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinations AS vacs
ON deaths.location=vacs.location
AND deaths.date=vacs.date 
WHERE deaths.continent IS NOT NULL

SELECT *
FROM PercentPopVaccinated