SELECT *
FROM CovidDealth
ORDER BY 3,4


--SELECT *
--FROM CovidVaccine
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--Looking at total_cases vs total_deaths
--Likelihood of dying if you contact covid in your state
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDealth
WHERE location LIKE '%state%'
AND continent IS NOT NULL
ORDER BY  1,2

--Looking at total_cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageInfected
FROM CovidDealth
--WHERE location LIKE '%state%'
ORDER BY  1,2

--Looking at countries with the Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases)AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDealth
--WHERE location LIKE 'Nig%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected Desc

--Showing countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM CovidDealth
--WHERE location LIKE 'Nig%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc

--Breaking it down by continent
SELECT continent, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM CovidDealth
--WHERE location LIKE 'Nig%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc

--Global Numbers
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths as bigint)) AS TotalNewDeath, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDealth
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY DeathPercentage Desc

--You can decide to view each data point from each continents

--SELECT continent,SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths as bigint)) AS TotalNewDeath, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 AS DeathPercentage
--FROM CovidDealth
--WHERE continent is NOT NULL
--GROUP BY continent
--ORDER BY DeathPercentage Desc


--Covid vaccine dataset
SELECT *
FROM CovidVaccine
WHERE continent IS NOT NULL
ORDER BY 3,4


--Lets join the CovidDeath table with CovidVaccine Table
SELECT *
FROM CovidDealth as cd
INNER JOIN CovidVaccine as cv
ON cd.location = cv.location
AND cd.date = cv.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,Cv.new_vaccinations)) OVER (Partition by Cd.Location Order by Cd.location, Cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDealth AS Cd
Join CovidVaccine AS Cv
	On Cd.location = Cv.location
	and Cd.date = Cd.date
where Cd.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Cd.continent, Cd.location, Cd.date, Cd.population, Cv.new_vaccinations
, SUM(CONVERT(bigint,Cv.new_vaccinations)) OVER (Partition by Cd.Location Order by Cd.location, Cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDealth Cd
Join CovidVaccine Cv
	On Cd.location = Cv.location
	and Cd.date = Cv.date
where Cd.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From Pop_vs_Vac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select Cd.continent, Cd.location, Cd.date, Cd.population, Cv.new_vaccinations
, SUM(CONVERT(bigint,Cv.new_vaccinations)) OVER (Partition by Cd.Location Order by Cd.location, Cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDealth Cd
Join CovidVaccine Cv
	On Cd.location = Cv.location
	and Cd.date = Cv.date
where Cd.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select Cd.continent, Cd.location, Cd.date, Cd.population, Cv.new_vaccinations
, SUM(CONVERT(bigint,Cv.new_vaccinations)) OVER (Partition by Cd.Location Order by Cd.location, Cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDealth Cd
Join CovidVaccine Cv
	On Cd.location = Cv.location
	and Cd.date = Cv.date
where Cd.continent is not null

SELECT *
FROM PercentPopulationVaccinated