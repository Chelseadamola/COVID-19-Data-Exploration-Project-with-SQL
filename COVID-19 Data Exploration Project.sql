select *
from [Data Exploration Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from [Data Exploration Project]..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from [Data Exploration Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases versus Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Data Exploration Project]..CovidDeaths
where location = 'Nigeria'
and continent is not null
order by 1,2


--Looking at Total cases versus Population
--Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Data Exploration Project]..CovidDeaths
where location = 'Nigeria'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
select location, population, max(total_cases) as TotalInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Data Exploration Project]..CovidDeaths
--where location = 'Nigeria'
Group by location, population
order by 4 desc

--Showing the Countries with the Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Data Exploration Project]..CovidDeaths
where continent is not null
Group by location
order by 2 desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Data Exploration Project]..CovidDeaths
where continent is not null
Group by continent
order by 2 desc


--Showing the Continents With the Highest Death Count Population
select Continent, max(cast(total_deaths as int)) as TotalDeathCount 
from [Data Exploration Project]..CovidDeaths
where continent is not null
Group by Continent
order by 2 desc


-- Global Numbers 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Data Exploration Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Data Exploration Project]..CovidDeaths as dea
join [Data Exploration Project]..CovidVaccinations as vac
on dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2,3


--USE CTE
With PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Data Exploration Project]..CovidDeaths as dea
join [Data Exploration Project]..CovidVaccinations as vac
on dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Dtae datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Data Exploration Project]..CovidDeaths as dea
join [Data Exploration Project]..CovidVaccinations as vac
on dea.location = vac.location
--where dea.continent is not null
and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data later for visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Data Exploration Project]..CovidDeaths as dea
join [Data Exploration Project]..CovidVaccinations as vac
on dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date


select *
from PercentPopulationVaccinated