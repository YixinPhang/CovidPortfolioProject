--Check the datasets
Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Death Percentages by Location
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by location, date

--Infection Rate by Location
Select location, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by location, population

--Highest Infection Rate by Population Country
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Return Locations with recent Death Count   
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International','Upper middle income', 'High income', 'lower middle income', 'low income')
group by location
order by TotalDeathCount desc

--Return Continents with recent Death Count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Return Location with their respective Death Percentages 
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1

--Create a temporary table with Death table joined to Vaccinatinated Table 
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

--Return Vaccination Rate By Location
Select *, (CumVaccinationsByLocation/Population)*100 as PercentVaccinated
From PopvsVac
order by 2,3

DROP Table if exists #PercentPopulationVaccinated
-- Create a new table for new vaccinations and amount of vaccinations by location
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

--Check Variation Percentage of Country 
Select *, (CumVaccinationsByLocation/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated
--where Location like'M%sia' 
order by 2,3

--Create view of vaccination percentages
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumVaccinationsByLocation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --dea.location like '%Kong%'
--order by 2,3 
