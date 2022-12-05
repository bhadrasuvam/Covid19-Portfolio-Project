-- Selecting the data we are going to be using 

Select location, date,total_cases,new_cases,total_deaths,population
From Portfoliodatabase..CovidDeaths
Order by 1,2

-- We are looking at Total Cases vs Total Deaths
-- It shows the likelihood of dying if you contract covid in your country
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfoliodatabase..CovidDeaths
WHERE location like '%states%'
Order by 1,2


-- We are looking at Total cases vs The population
-- Shows Here what percentage of the population has got covid
Select location, date,total_cases,total_deaths, population, (total_cases/population)*100 as PercCasesPopoulation
From Portfoliodatabase..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- We want to look at which country has the highest infection rate compared to population
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercPopoulationInfected
From Portfoliodatabase..CovidDeaths
--WHERE location like '%states%'
GROUP BY location,population
Order by 4 DESC

-- We will see the countries with the highest death count per population



Select location,MAX(cast(Total_deaths as int)) as TotalDeath
From Portfoliodatabase..CovidDeaths
-- Resolving the Location issue 
WHERE continent is not null    
GROUP BY location
Order by 2 DESC

-- Breaking things down by continent 

Select location,MAX(cast(Total_deaths as int)) as TotalDeath
From Portfoliodatabase..CovidDeaths
-- Resolving the Location issue 
WHERE continent is null and location not LIKE '%income'
GROUP BY location	
Order by 2 DESC  
--above I need to take care of the income segregation (can be used in Tableau)


-- I will see the total deaths according to the income parameter 
-- Look into why is this happening (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8542832/)

Select location,MAX(cast(Total_deaths as int)) as TotalDeath
From Portfoliodatabase..CovidDeaths
-- Resolving the Location issue 
WHERE continent is null and location LIKE '%income'
GROUP BY location	
Order by 2 DESC  

-- We will look into Global Numbers

Select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfoliodatabase..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY date
Order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfoliodatabase..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
--GROUP BY date
Order by 1,2

-- Lets look at Vaccination Table

Select *
From Portfoliodatabase..CovidVaccinations

-- We will Join two Table
--Looking at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition By dea.location Order by dea.location,dea.date) as RollingSumVaccination
From Portfoliodatabase..CovidDeaths dea
Join Portfoliodatabase..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--Usage of CTE
With PopvsVac(continent,location,date,population,new_vaccinations,RollingSumVaccination)as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition By dea.location Order by dea.location,dea.date) as RollingSumVaccination
From Portfoliodatabase..CovidDeaths dea
Join Portfoliodatabase..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
SELECT *, RollingSumVaccination/population * 100 as PercPopVaccinated
FROM PopvsVac


-- Creating view to store Data for later visualizations
Create view PercPopVaccinated as

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition By dea.location Order by dea.location,dea.date) as RollingSumVaccination
From Portfoliodatabase..CovidDeaths dea
Join Portfoliodatabase..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercPopVaccinated