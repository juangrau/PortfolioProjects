/*
	Creating the database
*/

create database PortfolioProject

/*
	Creating the tables
*/

CREATE TABLE [dbo].[CovidVaccinations](
	[iso_code] [varchar](50) NULL,
	[continent] [varchar](50) NULL,
	[location] [varchar](50) NULL,
	[date] [datetime] NULL,
	[total_tests] [varchar](50) NULL,
	[new_tests] [varchar](50) NULL,
	[total_tests_per_thousand] [varchar](50) NULL,
	[new_tests_per_thousand] [varchar](50) NULL,
	[new_tests_smoothed] [varchar](50) NULL,
	[new_tests_smoothed_per_thousand] [varchar](50) NULL,
	[positive_rate] [varchar](50) NULL,
	[tests_per_case] [varchar](50) NULL,
	[tests_units] [varchar](50) NULL,
	[total_vaccinations] [varchar](50) NULL,
	[people_vaccinated] [varchar](50) NULL,
	[people_fully_vaccinated] [varchar](50) NULL,
	[total_boosters] [varchar](50) NULL,
	[new_vaccinations] [varchar](50) NULL,
	[new_vaccinations_smoothed] [varchar](50) NULL,
	[total_vaccinations_per_hundred] [varchar](50) NULL,
	[people_vaccinated_per_hundred] [varchar](50) NULL,
	[people_fully_vaccinated_per_hundred] [varchar](50) NULL,
	[total_boosters_per_hundred] [varchar](50) NULL,
	[new_vaccinations_smoothed_per_million] [varchar](50) NULL,
	[new_people_vaccinated_smoothed] [varchar](50) NULL,
	[new_people_vaccinated_smoothed_per_hundred] [varchar](50) NULL,
	[stringency_index] [varchar](50) NULL,
	[population_density] [varchar](50) NULL,
	[median_age] [varchar](50) NULL,
	[aged_65_older] [varchar](50) NULL,
	[aged_70_older] [varchar](50) NULL,
	[gdp_per_capita] [varchar](50) NULL,
	[extreme_poverty] [varchar](50) NULL,
	[cardiovasc_death_rate] [varchar](50) NULL,
	[diabetes_prevalence] [varchar](50) NULL,
	[female_smokers] [varchar](50) NULL,
	[male_smokers] [varchar](50) NULL,
	[handwashing_facilities] [varchar](50) NULL,
	[hospital_beds_per_thousand] [varchar](50) NULL,
	[life_expectancy] [varchar](50) NULL,
	[human_development_index] [varchar](50) NULL,
	[population] [varchar](50) NULL,
	[excess_mortality_cumulative_absolute] [varchar](50) NULL,
	[excess_mortality_cumulative] [varchar](50) NULL,
	[excess_mortality] [varchar](50) NULL,
	[excess_mortality_cumulative_per_million] [varchar](50) NULL
)

CREATE TABLE [dbo].[CovidDeaths](
	[iso_code] [varchar](50) NULL,
	[continent] [varchar](50) NULL,
	[location] [varchar](50) NULL,
	[date] [datetime] NULL,
	[population] [varchar](50) NULL,
	[total_cases] [varchar](50) NULL,
	[new_cases] [varchar](50) NULL,
	[new_cases_smoothed] [varchar](50) NULL,
	[total_deaths] [varchar](50) NULL,
	[new_deaths] [varchar](50) NULL,
	[new_deaths_smoothed] [varchar](50) NULL,
	[total_cases_per_million] [varchar](50) NULL,
	[new_cases_per_million] [varchar](50) NULL,
	[new_cases_smoothed_per_million] [varchar](50) NULL,
	[total_deaths_per_million] [varchar](50) NULL,
	[new_deaths_per_million] [varchar](50) NULL,
	[new_deaths_smoothed_per_million] [varchar](50) NULL,
	[reproduction_rate] [varchar](50) NULL,
	[icu_patients] [varchar](50) NULL,
	[icu_patients_per_million] [varchar](50) NULL,
	[hosp_patients] [varchar](50) NULL,
	[hosp_patients_per_million] [varchar](50) NULL,
	[weekly_icu_admissions] [varchar](50) NULL,
	[weekly_icu_admissions_per_million] [varchar](50) NULL,
	[weekly_hosp_admissions] [varchar](50) NULL,
	[weekly_hosp_admissions_per_million] [varchar](50) NULL
)

/*
	The data was loaded using the tool
	Microsoft SQL Server Management Studio
*/


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