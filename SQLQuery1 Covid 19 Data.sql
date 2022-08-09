Select *
From Protfolioproject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--From Protfolioproject..Covidvacinations
--order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From Protfolioproject..CovidDeaths
order by 1, 2



-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Protfolioproject..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
-- Showes percentage of of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Protfolioproject..CovidDeaths
--where location like '%states%'
order by 1, 2


--Looking at Countries with highest infection rate compared to population


Select location, population, max(total_cases)as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
From Protfolioproject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From Protfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc


--Showing Continent with Highest Death Count
--Braking it down by Continent 
-- Removed Income Level


Select location, max(cast(total_deaths as int)) as TotalDeathCount
From Protfolioproject..CovidDeaths
--where location like '%states%'
where continent is null
AND location not like '%income%'
Group by location
Order by TotalDeathCount desc


--Global Numbers
--Total By Date

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Protfolioproject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by date
order by 1, 2


--Total Numbers Globally 


Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Protfolioproject..CovidDeaths
--where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2



--Looking at Total Popultion vs vacination
--Joining Tables
-- Numbers were to large to convet as int so needed to use bigint to exacute


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From Protfolioproject..CovidDeaths dea
join Protfolioproject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From Protfolioproject..CovidDeaths dea
join Protfolioproject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, RollingPeopleVaccinated/population*100 as RollingTotalPercentageVaccinated
from PopVsVac



--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations Numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From Protfolioproject..CovidDeaths dea
join Protfolioproject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, RollingPeopleVaccinated/population*100 as RollingTotalPercentageVaccinated
from #PercentPopulationVaccinated


--Creating View to Store Data for Later


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From Protfolioproject..CovidDeaths dea
join Protfolioproject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3