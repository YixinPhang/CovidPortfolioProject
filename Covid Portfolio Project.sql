Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by location, date

Select location, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by location, population

--Highest Infected by Population Country
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Highest Death by Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Continents with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as CasesByDay, sum(cast(new_deaths as int)) as DeathByDay, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentByDay
From PortfolioProject..CovidDeaths
where continent is not null
order by 1

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumVaccinationsByLocation)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumVaccinationsByLocation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --dea.location like '%Kong%'
--order by 2,3 
)
Select *, (CumVaccinationsByLocation/Population)*100 as PercentVaccinated
From PopvsVac
order by 2,3

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumVaccinationsByLocation numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumVaccinationsByLocation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --dea.location like '%Kong%'
--order by 2,3 

Select *, (CumVaccinationsByLocation/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated
where Location like'M%sia'
order by 2,3

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumVaccinationsByLocation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --dea.location like '%Kong%'
--order by 2,3 
