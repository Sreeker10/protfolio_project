use portpro
select location,date,total_cases,new_cases,total_deaths,population from dbo.coviddeaths order by 1,2


exec sp_help  'dbo.coviddeaths'

--alter table coviddeaths
--alter column 


-- Describes About the Death Rate of a Person based on Past Data 
-- and location. It uses total_cases and total_deaths in previous months to calculate it

select location,date,total_cases,total_deaths, (total_deaths * 1.0 / total_cases)*100 as DeathPercentage 
from dbo.coviddeaths 
where location like '%ndia' order by total_cases DESC

-- This is Here shows the percentage of Population infected by the disease
-- After the spread of disease

select location,total_cases,population, (total_cases*1.0/population)*100 as pop 
from dbo.coviddeaths where location like '%ndia' and total_cases is not null order by pop 

select location,population,max(total_cases) as Highest_infection,max((total_cases*1.0/population)*100) as InfectionRate
from dbo.coviddeaths group by location,population order by InfectionRate DEsc

-- Shows the maximum deaths in a location

-- here we added continent as not null for removing the unwanted continent data from getting selected

select location,max(total_deaths)as max_deaths from dbo.coviddeaths where continent is not null group by location order by max_deaths DESC ;


-- continent wise death's percentage and total death's

select continent,
round((sum(cast(isnull(total_deaths,0) as bigint))*1.0/sum(cast(isnull(total_cases,0) as bigint)))*100,2) as max_deaths,
max(cast(isnull(total_deaths,0) as bigint)) as totalDeaths,max(cast(isnull(total_cases,0) as bigint)) as totalCases
from dbo.coviddeaths where continent is not null group by continent order by max_deaths DESC;


select location, max(cast(total_deaths as int)) as TotalDeathCounts
from dbo.coviddeaths
where continent is null
group by location
order by TotalDeathCounts DESC



select continent, max(cast(total_deaths as int)) as TotalDeathCounts
from dbo.coviddeaths
where continent is not null
group by continent
order by TotalDeathCounts DESC

-- Both are the same

select continent,max(total_deaths) from dbo.coviddeaths where continent is not null group by continent;

-- Global Numbers

select location,total_cases,total_deaths, 
(total_deaths*1.0/total_cases)*100 as DeathPercentage
from dbo.coviddeaths
where continent is not null
order by location

select date,sum(new_cases) as total_cases ,sum(new_deaths) as TotalDeaths,
case
	when sum(new_cases)=0 then NUll
	else (sum(new_deaths)*1.0/sum(new_cases))*100
end as DeathPercentage
from dbo.coviddeaths
where continent is not null
group by date
order by date



select *
from dbo.covidVaccine
where continent is not null
order by location


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from dbo.coviddeaths dea
join dbo.covidVaccine vac
	on dea.iso_code=vac.iso_code and
	dea.date=vac.datee
where dea.continent is not null
order by 1,2


-- TEMP TABLE

drop table if exists #populationvaccinated
create table #populationvaccinated(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
Rollingvaccination numeric
)
insert into #populationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from dbo.coviddeaths dea
join dbo.covidVaccine vac
	on dea.iso_code=vac.iso_code and
	dea.date=vac.datee
where dea.continent is not null
order by 1,2

select * from #populationvaccinated

-- create view for later visualization

create view populationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingvaccination
from dbo.coviddeaths dea
join dbo.covidVaccine vac
	on dea.iso_code=vac.iso_code and
	dea.date=vac.datee
where dea.continent is not null
--order by 1,2