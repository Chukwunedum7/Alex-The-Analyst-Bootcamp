Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null


Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths

--Looking at Total cases vs Total deaths
--Shows the likelyhood of dying if one contracts Covid in Nigeria

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'Nigeria'
Order by 1,2

--Looking at Total cases vs Population
--Shows the percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'Nigeria'
Order by 1,2

--Looking at Countries with Highest infection rates compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
From [Portfolio Project]..CovidDeaths
--Where location like 'Nigeria'
Group by location, population
Order by InfectionPercentage desc

--Showing Countries with Highest death counts per population

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount desc

--Using Continent (GLOBAL)

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as 
DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
Order by 2, 3

--NOW JOINING WITH COVID VACCINATION TABLE

--set ansi_warnings off
--Go
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal(18,2)))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location= vac.location
and dea.date= vac.date
Where dea.continent is not null

--POPULATION VS VACCINATED


--USING CTE

With PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal(18,2)))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location= vac.location
and dea.date= vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--USING TEMP TABLE

Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal(18,2)))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location= vac.location
and dea.date= vac.date
Where dea.continent is not null

--Select *, (RollingPeopleVaccinated/Population)*100
--From  #PercentPopulationVaccinated

--Create View PercentagePopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal(18,2)))
--OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--From [Portfolio Project]..CovidDeaths dea
--Join [Portfolio Project]..CovidVaccinations vac
--ON dea.location= vac.location
--and dea.date= vac.date
--Where dea.continent is not null
