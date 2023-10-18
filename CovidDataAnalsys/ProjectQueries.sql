use PortfolioProject

select *
from PortfolioProject..CovidDeaths
order by 4,3

select *
from PortfolioProject..CovidVaccinations
order by 4,3

/*
	Select the Date that we are going to be using
*/

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you were infected with Coronavirus in you country
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathRate
from PortfolioProject..CovidDeaths
where total_cases > 0 and location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got covid
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 PercentPopulationInfected
from PortfolioProject..CovidDeaths
where total_cases > 0 and location = 'United States'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where total_cases > 0
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest Death Count
select location, population, max(cast(total_deaths as int)) as HighestDeathsCount
from PortfolioProject..CovidDeaths
where continent <> '' 
group by location, population
order by HighestDeathsCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
select location, max(cast(total_deaths as int)) as HighestDeathsCount
from PortfolioProject..CovidDeaths
where continent = '' 
group by location
order by HighestDeathsCount desc


-- Showing continents with the hihest death count per population
select continent, max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent <> ''
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS BY DATE
select date, SUM(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths, 
(sum(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
group by date
having SUM(cast(new_cases as int)) > 0
order by date

-- GLOBAL NUMBERS TOTAL
select SUM(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths, 
(sum(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths



/* 
	Now lets work with the CovidVaccinations Table
*/


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.date) --, dea.location)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' and dea.date > '2021-01-10' --dea.location = 'Albania' and 
order by 2,3


/*
	USING CTE Lets use the new created column (RollingPeopleVaccinated)
	to calculate something else. 
*/

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.date) --, dea.location)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' and dea.date > '2021-01-10' -- and dea.location = 'Albania'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


/*
	LET'S CALCULATE THE SAME VALUE BUT USING TEMP TABLE INSTEAD OF CTE
*/

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(256),
location nvarchar(256),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, cast(dea.population as float), cast(vac.new_vaccinations as float),
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.date) --, dea.location)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' -- and dea.date > '2021-01-10' --dea.location = 'Albania' and 
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

/* 
	Creating View to store data for later visualizations
*/

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, cast(dea.population as float) as population, cast(vac.new_vaccinations as float) 
as new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' -- and dea.date > '2021-01-10' --dea.location = 'Albania' and 
--order by 2,3

select *
from PercentPopulationVaccinated