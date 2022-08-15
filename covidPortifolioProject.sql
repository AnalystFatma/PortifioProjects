
select * from [covid-deathes]
where continent is not null
order by date

select * from dbo.[covid-vaccions]
order by date

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from [covid-deathes]
where continent is not null
order by 1,2


alter table dbo.[covid-deathes]
alter COLUMN total_cases FLOAT

alter table dbo.[covid-deathes]
alter COLUMN total_deaths FLOAT

-- looking at total cases vd total deathes
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from [covid-deathes]
where [location] LIKE '%states' and continent is not null
order by 1,2

--lloking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from [covid-deathes]
where [location] LIKE '%states' and continent is not null
order by 1,2

--lloking at countries with highest infection rate compared to populaiton
select location,  population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as percentPopulationInfected
from [covid-deathes]
--where [location] LIKE '%states' and  continent is not null
GROUP BY [location],population
order by 4 desc


--showing countries with highest death count for population
select location,  max(cast(total_deaths as int)) as totalDeathCount
from [covid-deathes]
where continent is not null
GROUP BY [location],population
ORDER BY 2 DESC

--let's break things down by continent

--showing the continent with the highest death count
select continent,  max(total_deaths) as totalDeathCount
from [covid-deathes]
where continent is not null
GROUP BY continent
ORDER BY 2 DESC

alter table dbo.[covid-deathes]
alter COLUMN new_cases FLOAT

alter table dbo.[covid-deathes]
alter COLUMN new_deaths FLOAT

--global numbers 
select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths,
sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from [covid-deathes]
where continent is not null
group by date 

--global numbers 
select  sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths,
sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from [covid-deathes]
where continent is not null

---------------------join--------------------------

 select * from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date

--looking at total population vs vaccination
 select dea.continent, dea.[location], dea.[date],dea.population, vac.new_vaccinations 
 , sum(vac.new_vaccinations) 
 from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

alter table dbo.[covid-vaccions]
alter COLUMN new_vaccinations FLOAT

select dea.continent, dea.[location], dea.[date],dea.population, vac.new_vaccinations 
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
 AS rollingPeopleVaccinated
--/population --how many people in that country vaccinated
 from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 ORDER BY 2,3

--use CTE
with PopvsVac (continent, location, date, population, new_vaccinations ,rollingPeopleVaccinated)
AS
(
select dea.continent, dea.[location], dea.[date],dea.population, vac.new_vaccinations 
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
 AS rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100 --how many people in that country vaccinated
 from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --ORDER BY 2,3
)
select * , (rollingPeopleVaccinated/population)*100 as peopleVaccinatedPercent
from PopvsVac

--temp table

drop table if exists #PersentPopulationVaccinated 
CREATE TABLE #PersentPopulationVaccinated
(
continent nvarchar(50),
location nvarchar(50),
Date date,
population numeric,
new_vaccinations NUMERIC,
rollingPeopleVaccinated NUMERIC
)

insert into #PersentPopulationVaccinated
select dea.continent, dea.[location], dea.[date],dea.population, vac.new_vaccinations 
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
 AS rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100 --how many people in that country vaccinated
 from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --ORDER BY 2,3

select * , (rollingPeopleVaccinated/population)*100 as peopleVaccinatedPercent
from #PersentPopulationVaccinated


--creating view to store data for later visualizations
create VIEW PersentPopulationVaccinated as
select dea.continent, dea.[location], dea.[date],dea.population, vac.new_vaccinations 
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
 AS rollingPeopleVaccinated
 from [covid-deathes] as dea
 join dbo.[covid-vaccions] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --ORDER BY 2,3 

 select * from PersentPopulationVaccinated
