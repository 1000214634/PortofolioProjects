Select *
FROM PortofolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--FROM PortofolioProject..CovidVaccinations$
--order by 3,4


--Select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
from PortofolioProject..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
where location like'%Egy%' and continent is not null
order by 1,2


--looking at total cases vs population
--Shows what percentage of population got Covid
Select location,date,total_cases,population, (total_cases/population)*100  as PercentPopulationInfected
from PortofolioProject..CovidDeaths$
--where location like '%Egy%'
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select location,MAX(total_cases)as HighestInfectionCount,population, MAX(total_cases/population)*100  as PercentPopulationInfected
from PortofolioProject..CovidDeaths$
--where location like '%Egy%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count per Population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths$
--where location like '%Egy%'
where continent is not null
group by location
order by TotalDeathCount desc

--let's break things down by continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths$
--where location like '%Egy%'
where continent is  not null
group by continent
order by TotalDeathCount desc


--Global numbers
--Â‰ﬁ”„Â« ⁄·Ì Õ”» «·œÌ 
Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death ,sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
--where location like'%Egy%' 
where continent is not null
--group by date
order by 1,2

--looking at total population vs Vaccinations

Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Using CTE

With PopvsVac(continent,location,population,date,new_vaccinations,RollingPeopleVaccinated)
as

(Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #percentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




