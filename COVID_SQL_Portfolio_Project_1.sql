--COVID DEATHS

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_1..CovidDeaths
Where continent is not null
Order by 1,2

--Convert column type
Alter table portfolio_1..CovidDeaths
--alter column total_cases float
--alter column total_deaths float
--alter column new_deaths float
alter column new_cases float

--Total cases vs. total deaths (Shows the daily percentage of dying from COVID in Nigeria)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Portfolio_1..CovidDeaths
Where location like '%nigeria%' and continent is not null
Order by 1,2

--Total cases vs. population (Shows percentage of population that got COVID)
Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From Portfolio_1..CovidDeaths
Where location like '%nigeria%' and continent is not null
Order by 1,2

--Countries with highest infection rate compared with population
Select location, population, max(total_cases) as HigestInfectionCount, max((total_cases/population)) * 100 
as MaxPercentPopulationInfected
From Portfolio_1..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by location, population
Order by 4 desc

--Countries with highest death count per population
Select location, population, max(total_deaths) as TotalDeathCount
From Portfolio_1..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by location, population
Order by 3 desc

--BREAKING THINGS DOWN BY CONTINENT

--Total cases vs. total deaths (Shows the daily percentage of dying from COVID in Nigeria)
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Portfolio_1..CovidDeaths
Where continent is not null
Order by 1,2

--Total cases vs. population (Shows percentage of population that got COVID)
Select continent, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From Portfolio_1..CovidDeaths
Where continent is not null
Order by 1,2

--Continents with highest infection rate compared with population
Select continent, population, max(total_cases) as HigestInfectionCount, max((total_cases/population)) * 100 
as MaxPercentPopulationInfected
From Portfolio_1..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by continent, population
Order by 4 desc

--Continents with highest death count per population
Select location, max(total_deaths) as TotalDeathCount
From Portfolio_1..CovidDeaths
--Where location like '%nigeria%'
Where continent is null
Group by location
Order by 2 desc

Select continent, max(total_deaths) as TotalDeathCount
From Portfolio_1..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by continent
Order by 2 desc

--GLOBAL NUMBERS

--Daily global cases
Select date, sum(new_cases) as total_cases
From Portfolio_1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Daily global deaths
Select date, sum(new_deaths) as total_deaths
From Portfolio_1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Daily global death percentage
Select date, sum(new_deaths) / nullif(sum(new_cases),0) * 100 as DeathPercentage
From Portfolio_1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / nullif(sum(new_cases),0) * 100 
as DeathPercentage
From Portfolio_1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Summary of global data for total_cases, total_deaths and death_percentage
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / nullif(sum(new_cases),0) * 100 
as DeathPercentage
From Portfolio_1..CovidDeaths
Where continent is not null


--COVID VACCINATION

--JOINING CovidVaccination to CovidDeath

Select * from Portfolio_1..CovidDeaths dea
Join Portfolio_1..CovidVaccination vac
On dea.location = vac.location and dea.date = vac.date

--Converting column type
Alter table Portfolio_1..CovidVaccination
alter column new_vaccinations float

--Total population vs total vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_1..CovidDeaths dea
Join Portfolio_1..CovidVaccination vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use a CTE to determine the population vs total number of people vaccinated
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_1..CovidDeaths dea
Join Portfolio_1..CovidVaccination vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated / Population) * 100 as PercentPopulationVaccinated
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_1..CovidDeaths dea
Join Portfolio_1..CovidVaccination vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_1..CovidDeaths dea
Join Portfolio_1..CovidVaccination vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null