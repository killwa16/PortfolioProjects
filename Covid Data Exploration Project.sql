Select location, date, total_cases, new_cases, total_deaths, population
From projects..CovidDeaths
Where continent is not null
Order by 1, 2

-- shows the mortality rate
Select location, date, total_cases, total_deaths, 
(total_deaths/total_cases * 100) as mortality_rate
From projects..CovidDeaths
Where location ='Philippines'
and continent is not null
Order by 1, 2 DESC

-- shows the case percentage
Select location, date, total_cases, population, 
(total_cases/population * 100) as cases_rate
From projects..CovidDeaths
Where location ='Philippines'
and continent is not null
Order by 1, 2 DESC

-- looking at the number of cases per country
Select location, population, MAX(total_cases) as Case_count, 
MAX((total_cases/population * 100)) as cases_rate
From projects..CovidDeaths
Where continent is not null
GROUP by location, population
Order by Case_count DESC

--looking at the death count per country
Select location, MAX(cast(total_deaths as int)) as death_count
From projects..CovidDeaths
Where continent is not null
GROUP by location
Order by death_count desc

-- looking at the deaths by continent
Select location, MAX(cast(total_deaths as int)) as death_count
From projects..CovidDeaths
Where continent is null and
location ='Europe'or location = 'Asia' or
location ='North America'or location = 'South America' or
location ='Oceania'or location = 'Africa' or location= 'Antartica'
GROUP by location
Order by death_count desc

-- total cases and deaths worldwide
Select SUM(cast(new_deaths as int)) as death_count,
SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Mortality_Rate
From projects..CovidDeaths
Where continent is not null
order by 1,2


-- looking at vaccinated people worldwide
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS Cummulative_sum_vaccinated
from projects..CovidDeaths dea
JOIN projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE
with PopulationVSVaccination (continent, location, date, population, New_vaccinations, Cummulative_sum_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS Cummulative_sum_vaccinated
from projects..CovidDeaths dea
JOIN projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT * , (Cummulative_sum_vaccinated/population)* 100 AS Cummulative_percentage_vaccinated
FROM PopulationVSVaccination



-- Using a temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccinations numeric, Cummulative_sum_vaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS Cummulative_sum_vaccinated
from projects..CovidDeaths dea
JOIN projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * , (Cummulative_sum_vaccinated/population)* 100 AS Cummulative_percentage_vaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS Cummulative_sum_vaccinated
from projects..CovidDeaths dea
JOIN projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Create View MortalityRatePH as
Select location, date, total_cases, total_deaths, 
(total_deaths/total_cases * 100) as mortality_rate
From projects..CovidDeaths
Where location ='Philippines'
and continent is not null
--Order by 1, 2 DESC


Create view CasesRate as
Select location, date, total_cases, population, 
(total_cases/population * 100) as cases_rate
From projects..CovidDeaths
Where location ='Philippines'
and continent is not null
--Order by 1, 2 DESC


Create View CasesPerCountry as
Select location, population, MAX(total_cases) as Case_count, 
MAX((total_cases/population * 100)) as cases_rate
From projects..CovidDeaths
Where continent is not null
GROUP by location, population
--Order by Case_count DESC


Create view DeathPerCountry as
Select location, MAX(cast(total_deaths as int)) as death_count
From projects..CovidDeaths
Where continent is not null
GROUP by location
--Order by death_count desc