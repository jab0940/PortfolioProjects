Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select the Data used 

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths$
order By 1,2

--Analysing the Total Cases vs Total cases
--Shows the likelyhood of dying if you contract covid in the United Kingdom
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%kingdom'
order By 1,2

--Analysing countries with the highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom'
Group by location, population
order By PercentagePopulationInfected desc

--Displaying Countries with highest Daeth Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
Order by TotalDeathCount desc

--Displaying Total Deaths by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Displaying the location by continent Total Deaths count 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
Order by TotalDeathCount desc


--Displaying global numbers by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))
as total_deaths, SUM(cast(new_deaths as int))/ SUM (new_cases)*100 as DeathPercetage 
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom'
where continent is not null
Group by date
order By 1,2

--Retrieving total number of cases, deaths and death percentage Globally 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))
as total_deaths, SUM(cast(new_deaths as int))/ SUM (new_cases)*100 as DeathPercetage 
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom'
where continent is not null
--Group by date
order By 1,2


--Retrieving the data from Total Population vs Vaccinations
Select *
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date

--Exploring continent, location, data and poulation with vaccine numbers
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Implementing CTE(Common Table Expression)

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations 

Create View PercentagePopulationVacccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3