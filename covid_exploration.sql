-- Looking at an specific country.
-- Creating a temporary table with the data we will need.
SELECT location, date, total_cases, new_cases, total_deaths, population
INTO "DeathData"
FROM "CovidDeaths"
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at the death rate of all cases in Brazil.
SELECT *, (total_deaths / total_cases) * 100 AS death_percentage
FROM "DeathData"
WHERE location LIKE 'Brazil'
ORDER BY date;

-- Looking at the percentage of the population that got sick with covid in Brazil.
SELECT *, (total_cases / population) * 100 AS pop_covid_rate
FROM "DeathData"
WHERE location LIKE 'Brazil'
ORDER BY date;



-- Checking the continents.
-- Looking at countries with the highest infection rate.
SELECT location, population, MAX(total_cases) AS highest_infection_count, Max((total_cases / population)) * 100 AS pop_covid_rate
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pop_covid_rate DESC;

-- Looking at death count by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;



-- Checking the global situation.
-- Cases, deaths and death percentage per day.
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Total cases, deaths and death percentage average on the whole world.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM "CovidDeaths"
WHERE continent IS NOT NULL;



-- Working with CovidVaccinations table.
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
	SELECT
	"CovidDeaths".continent,
	"CovidDeaths".location,
	"CovidDeaths".date,
	"CovidDeaths".population,
	"CovidVaccinations".new_vaccinations,
	SUM(CAST("CovidVaccinations".new_vaccinations AS INT)) OVER (PARTITION BY "CovidDeaths".location ORDER BY "CovidDeaths".location, "CovidDeaths".date) AS RollingPeopleVaccinated
	FROM "CovidDeaths"
	JOIN "CovidVaccinations" ON "CovidDeaths".location = "CovidVaccinations".location AND "CovidDeaths".date = "CovidVaccinations".date
	WHERE "CovidDeaths".continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated / population) * 100 AS percentage_of_people_vaccinated
FROM PopVsVac;



-- Creating a temporary table of vaccinations.
CREATE TABLE PercentPopulationVaccinated(
	continent CHAR(255),
	location CHAR(255),
	date DATE,
	population NUMERIC,
	new_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
	SELECT
		"CovidDeaths".continent,
		"CovidDeaths".location,
		"CovidDeaths".date,
		"CovidDeaths".population,
		"CovidVaccinations".new_vaccinations,
	SUM(CAST("CovidVaccinations".new_vaccinations AS INT)) OVER (PARTITION BY "CovidDeaths".location ORDER BY "CovidDeaths".location, "CovidDeaths".date) AS RollingPeopleVaccinated
	FROM "CovidDeaths"
	JOIN "CovidVaccinations" ON "CovidDeaths".location = "CovidVaccinations".location AND "CovidDeaths".date = "CovidVaccinations".date
	WHERE "CovidDeaths".continent IS NOT NULL
	
SELECT *, (RollingPeopleVaccinated / population) * 100 AS percentage_of_people_vaccinated
FROM PercentPopulationVaccinated



-- Creating a view for data visualization.
CREATE VIEW PopulationVaccinated AS (
SELECT
	"CovidDeaths".continent,
	"CovidDeaths".location,
	"CovidDeaths".date,
	"CovidDeaths".population,
	"CovidVaccinations".new_vaccinations,
SUM(CAST("CovidVaccinations".new_vaccinations AS INT)) OVER (PARTITION BY "CovidDeaths".location ORDER BY "CovidDeaths".location, "CovidDeaths".date) AS RollingPeopleVaccinated
FROM "CovidDeaths"
JOIN "CovidVaccinations" ON "CovidDeaths".location = "CovidVaccinations".location AND "CovidDeaths".date = "CovidVaccinations".date
WHERE "CovidDeaths".continent IS NOT NULL
)