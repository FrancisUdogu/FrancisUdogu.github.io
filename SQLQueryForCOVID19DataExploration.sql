SELECT * 
FROM SqlPortfolioProject.dbo.CovidDeaths
ORDER BY 3, 4


SELECT * 
FROM SqlPortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM SqlPortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--looking at the Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the Population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Percentage
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2

--Looking at Countries with the highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Percentage
FROM SqlPortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY Population_Percentage DESC

--Countries with the Highest Death Count per Population

SELECT location, MAX(Total_deaths) AS TotalDeathCount
FROM SqlPortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC 

--We need to "cast" the above Total_deaths as a Numeric (integer)

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM SqlPortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT * 
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

--Now let's rewrite the query for casting total_deaths to get the Countries with the Highest Death Count per Population
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SqlPortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM SqlPortfolioProject.dbo.CovidVaccinations

--Looking at Total Population vs Vaccinations

SELECT *
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--Now to look at the Total Population vs Vaccinations
--Use CTE 

With PopvsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Using TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM SqlPortfolioProject.dbo.CovidDeaths dea
JOIN SqlPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2





