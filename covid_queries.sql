--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to be using 
SELECT location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 
--Shows Likehood of dying if you contract covid in your country

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like  '%Tur%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date,total_cases, population, (total_cases/population)*100 as CaughtPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 as CaughtPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
GROUP BY Location, population
ORDER BY CaughtPercentage DESC

--Showing Countries with Highest Death Count per Population

SELECT location,population, MAX(cast(total_deaths as int)) AS HighestDeathCount  /* cast fonksiyonu totaldeaths sütununu int yaptı*/
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY HighestDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc




--GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like  '%Tur%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


/* vaccination rates*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	ORDER BY 3,4


-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	WHERE dea.continent is not null
	ORDER BY 2,3


	--USE CTE

WITH POPvsVAC (Continent,Location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
	SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	WHERE dea.continent is not null
	--ORDER BY 2,3
) 	
SELECT *,(RollingPeopleVaccinated/population)*100
FROM POPvsVAC







--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE view 
PercentagePopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	WHERE dea.continent is not null
	--ORDER BY 2,3