/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--COVID DEATHS
SELECT * FROM CovidDeaths
WHERE 
	continent is NOT NULL 
ORDER BY 3, 4


--COVID VACCINATIONS
select *
FROM CovidVaccinations
WHERE 
	continent is NOT NULL 
ORDER BY 3, 4


--Select Data that we are going to be using
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	CovidDeaths
WHERE 
	continent is NOT NULL
ORDER BY 1,2

--Loking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT
	location,
	date, 
	total_cases, 
	total_deaths, 
	(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM
	CovidDeaths
WHERE 
	location LIKE '%Canada%'
	AND continent is NOT NULL
ORDER BY 
	1,2 DESC


--Loking at Total Cases vs Population
--Shows what percentage of population got covid on daily bases (datewise)

SELECT
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population) * 100 as  PercentageOfPopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER by 1,4 DESC


-- Looking at countries with highest infection rate compared to population(Shows what percentage of population got covid)
SELECT 
	location, 
	population, 
	MAX(Total_cases) as HighestInfectionRate, 
	MAX(total_cases/population)* 100 as PercentageOfPopulationInfected
from CovidDeaths
where continent is NOT NULL
GROUP BY
	location, population
ORDER BY
	PercentageOfPopulationInfected desc


--Countries with highinfection rate by Month/Year (this is the one i will use for visualization)

SELECT 
	date,
	location, 
	population, 
	MAX(Total_cases) as HighestInfectionRate, 
	MAX(total_cases/population)* 100 as PercentageOfPopulationInfected
from CovidDeaths
where continent is NOT NULL
GROUP BY
	date,location, population
ORDER BY
	PercentageOfPopulationInfected desc


--Showing Countries with HighestDeath Count per population
SELECT
	location, 
	MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continent with highest death count per population

SELECT 
	continent, 
	MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT  
	SUM(new_cases) as Totalcases, SUM(cast (new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
FROM 
	CovidDeaths
WHERE 
	continent is not null




--Looking at Total Population Vs Vaccinations
6414


--USING CTE

With PopvsVac (Continent, Location, Date, population, new_vaccinations, TotalPeopleVacinated)
as
(
Select Deaths.continent, deaths.location, Deaths.date, population, Vaccine.new_vaccinations
,SUM(cast (Vaccine.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location,
deaths.date) as TotalPeopleVacinated
from CovidDeaths Deaths
JOIN CovidVaccinations Vaccine 
ON Deaths.location = Vaccine.location
and Deaths.date = Vaccine.date
where deaths.continent is not null
)
Select *, (TotalPeopleVacinated/population)*100 as TotalPercentageVacinated
From PopvsVac


--TEMP TABLE 

DROP Table if exists #PercentageOfPeopleVacinated 
CREATE TABLE #PercentageOfPeopleVacinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
new_vaccinations numeric,
TotalPeopleVacinated numeric,
)

INSERT INTO #PercentageOfPeopleVacinated
Select Deaths.continent, deaths.location, Deaths.date,population, Vaccine.new_vaccinations
,SUM(cast (Vaccine.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as TotalPeopleVacinated
--(TotalPeopleVacinated/population)*100
from CovidDeaths Deaths
JOIN CovidVaccinations Vaccine 
ON Deaths.location = Vaccine.location
and Deaths.date = Vaccine.date
where deaths.continent is not null
order by 2,3

Select *, (TotalPeopleVacinated/population)*100 as TotalPercentageVacinated
From #PercentageOfPeopleVacinated


--CREATING VIEW TO STORE DATA FOR  LATER VISUALIZATION

Create View TotalPeopleVacinated as
Select Deaths.continent, deaths.location, Deaths.date,population, Vaccine.new_vaccinations
,SUM(cast (Vaccine.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as TotalPeopleVacinated
from CovidDeaths Deaths
JOIN CovidVaccinations Vaccine 
ON Deaths.location = Vaccine.location
and Deaths.date = Vaccine.date
where deaths.continent is not null
