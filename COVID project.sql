select *
from portfolioproject.dbo.coviddeath$
where continent is not null
order by 3,4

--select *
--from portfolioproject.dbo.covidvaccination$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.dbo.coviddeath$
order by 1, 2

--looking at total cases vs total deaths
select location, date, total_cases, total_deaths, cast(total_deaths as decimal)/total_cases*100 as deathpercentage
from portfolioproject.dbo.coviddeath$
where location like '%states%'
order by 1, 2

--looking at total cases vs population
select location, date, population, total_cases, CAST(total_cases as decimal)/population*100 as percentpopulation
from portfolioproject.dbo.coviddeath$
--where location like '%states%'
order by 1, 2

--looking at countries with highest infection rates compared to population
select location, population, max(total_cases) as highestinfectioncount, max(cast(total_cases as decimal))/population*100 as percentpopulationinfected
from portfolioproject.dbo.coviddeath$
group by location, population
order by percentpopulationinfected desc

--looking at countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeath$
where continent is not null
group by location
order by totaldeathcount desc


--breaking down by continents
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeath$
where continent is not null
group by continent
order by totaldeathcount desc

--looking at continents with highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeath$
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases), 0)*100 as deathpercentage
from portfolioproject.dbo.coviddeath$
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(convert(float, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject.dbo.coviddeath$ as dea
join portfolioproject.dbo.covidvaccination$ as vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3

--CTE
with popvsvacc (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(convert(float, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject.dbo.coviddeath$ as dea
join portfolioproject.dbo.covidvaccination$ as vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvacc

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
loctaion nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(convert(float, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject.dbo.coviddeath$ as dea
join portfolioproject.dbo.covidvaccination$ as vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(convert(float, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject.dbo.coviddeath$ as dea
join portfolioproject.dbo.covidvaccination$ as vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated
