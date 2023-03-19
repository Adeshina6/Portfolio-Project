select * from [dbo].[CovidDeaths] 
where continent is not null
order by 3, 4

--Selecting data we're going to use

select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population from dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking Total Deaths vs. Total Cases showing likelihood of dying

select Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as DeathPercentage from dbo.CovidDeaths 
--where location like '%Nigeria%'
where continent is not null
order by 1,2

--looking Total Cases vs Population showing Percentage of population getting infected with Covid
select Location, Date, Population,  Total_Cases, (total_cases/population)*100 as InfectionRate  from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
order by 1,2

--Looking at countries with highest infectionRate compared to population
select Location, Population,  max(Total_Cases) as HighestIinfectionCount, max((total_cases/population))*100 as InfectionRate  from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by InfectionRate desc

--Showing countries with highest Deathcount per Population and DeathRate
select Location, Population,  max(Total_Deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathRate  from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by DeathRate desc

--Showing countries with highest Deathcount per Population
select Location, Population, max(cast(Total_Deaths as int)) as HighestDeathCount from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location, Population
order by HighestDeathCount desc

--BREAKING DOWN BY CONTINENT

--Showing continent with the HighestDeathCount per population 


select continent, max(cast(Total_Deaths as int)) as HighestDeathCount from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS
select Date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage 
from dbo.CovidDeaths 
--where location like '%Nigeria%' 
where continent is not null
group by date
order by 1,2


--Looking at Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVccinated
from [CovidDeaths] dea
join [CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (Continent, Location,Date, Population, New_vaccinations, RollingPeopleVccinated)
as 

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVccinated
from [CovidDeaths] dea
join [CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVccinated/Population)*100 from PopvsVac


--USE TEMP TABLE 
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(Continent Nvarchar(255)
,Location Nvarchar(255)
,Date datetime
,Population numeric
,New_Vaccinations numeric
,RollingPeopleVccinated numeric)


insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVccinated
from [CovidDeaths] dea
join [CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVccinated/Population)*100 from #PercentPopulationVaccinated



--Creating a View for later Visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVccinated
from [CovidDeaths] dea
join [CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3




