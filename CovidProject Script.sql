select * 
from covidDeaths 
order by 3,4

--select * 
--from covidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
where continent is not null
order by 1,2

-- Death Percentage in a particular area.
select location, date, total_cases, total_deaths, (convert (float,total_deaths)/CONVERT(float, total_cases)*100) as DeathPercentage
from covidDeaths
where location like 'india'
order by 2

-- Chances of getting Covid.
select location, date, population, total_cases,  (total_cases/population)*100 as CovidInfectedPercentage
from covidDeaths
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to population.
select location, population, max(cast (total_cases as int)) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from covidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is not null
group by location
order by totalDeathcount desc

--Continents with Highest Death Count per Population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathcount desc

--GLOBAL Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case 
when sum(new_cases)>0
then (sum(cast(new_deaths as int))/sum(new_cases)* 100) 
else 0
end as DeathPercentage
from covidDeaths
where continent is not null 
group by date
order by 1,2

--Global on each Day
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case 
when sum(new_cases)>0
then (sum(cast(new_deaths as int))/sum(new_cases)* 100) 
else 0
end as DeathPercentage
from covidDeaths
where continent is not null 
order by 1,2



--Joining Tables
select * 
from covidDeaths death
join covidVaccinations vac
on death.location= vac.location
and death.date =vac.date

--Total Population vs Vaccination
select death.continent, death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location) as RollingPeopleVaccinated
from covidDeaths death
join covidVaccinations vac
on death.location= vac.location
and death.date =vac.date
where death.continent is not null
order by 2,3


--Using CTE

with PopvsVac ( continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select death.continent, death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location) as RollingPeopleVaccinated
from covidDeaths death
join covidVaccinations vac
on death.location= vac.location
and death.date =vac.date
where death.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)/100
from PopvsVac

--TEMP Table

drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent, death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location) as RollingPeopleVaccinated
from covidDeaths death
join covidVaccinations vac
on death.location= vac.location
and death.date =vac.date
where death.continent is not null

Select * , (RollingPeopleVaccinated/population)/100
from #PercentPopulationVaccinated

--Creating Views

create view PercentPopulationVaccinated as 
select death.continent, death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location) as RollingPeopleVaccinated
from covidDeaths death
join covidVaccinations vac
on death.location= vac.location
and death.date =vac.date
where death.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated