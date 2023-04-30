-- USE Portfolioproject
-- SELECT *
-- FROM coviddeaths
--ORDER BY location, date

--USE Portfolioproject
--SELECT *
--FROM covidvaccination
--ORDER BY location, date

--Select the data we will be using
USE Portfolioproject
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM coviddeaths
--ORDER BY location, date

--we'll be looking at the percentage of deaths per case
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY location, date

-- we'll be looking at the percentage of total cases per population
-- This shows what percentage of the population has covid.
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulaionInfected
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY location, date

-- Looking at countries with the highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulaionInfected
FROM coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulaionInfected DESC

-- BREAKING THINGS DOWN BY CONTINENTS
-- Showing continents with the highest death counts per population
SELECT location, population, MAX(cast(total_deaths as int) AS TotalDeathcount
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulaionDeaths DESC

-- GET THE GLOBAL RECORD
SELECT sum(new_cases) AS total_cases, sum(cast(new_deaths AS int)) AS total_deaths, 
		sum(cast(new_deaths AS int))/sum(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY total_cases, total_deaths

-- Looking at Total population vs vaccination
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM coviddeaths cd
JOIN covidvaccination cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY location, date

-- USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM coviddeaths cd
JOIN covidvaccination cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
-- ORDER BY location, date
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM coviddeaths cd
JOIN covidvaccination cv
	ON cd.location = cv.location
	and cd.date = cv.date
-- WHERE cd.continent is not null
-- ORDER BY location, date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create Views for Data visualization
CREATE VIEW PercentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM coviddeaths cd
JOIN covidvaccination cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
-- ORDER BY location, date


SELECT *
FROM PercentPopulationVaccinated