select *
from PROJECTPORTFOLIO..COVIDDEATH
where continent is not null
order by 3,4

select *
from PROJECTPORTFOLIO..COVIDVACINATION
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PROJECTPORTFOLIO..COVIDDEATH
order by 1,2

--total cases vs total deaths
--Likelihood of no death id you contract covid in nigeria presently

select location, date, total_cases, total_deaths, (CAST(total_deaths as numeric)/cast(total_cases as numeric))*100 as DeathPercent
from PROJECTPORTFOLIO..COVIDDEATH
where location like '%Nigeria%'
and continent is not null
order by 1,2


--Total cases vs population
-- shows number of people that contracted covid from the onset till date
-- As at August 4th 2023, 10 new cases were discovered in Nigeria making a total of 266675 cases
select location, date, population, total_cases, (CAST(total_cases as numeric)/cast(population as numeric))*100 as CasePercent
from PROJECTPORTFOLIO..COVIDDEATH
where location like '%Nigeria%'
order by 1,2

--all countries infection rate to total population

select location, population, Max(cast(total_cases as int)) as CountriesHighestCases, Max((CAST(total_cases as int)/population))*100 as CountriesPopulationPercent
from PROJECTPORTFOLIO..COVIDDEATH
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by CountriesPopulationPercent desc


--shows countries total death per population

select location, max(cast(total_deaths as int)) as Deathperpopulation
from PROJECTPORTFOLIO..COVIDDEATH
--where location like '%Nigeria%'
where continent is not null
group by location
order by Deathperpopulation desc


--compare by continent
select continent, max(cast(total_deaths as int)) as Deathperpopulation
from PROJECTPORTFOLIO..COVIDDEATH
--where location like '%Nigeria%'
where continent is not null
group by continent
order by Deathperpopulation desc

--GLOBAL NUMBERS


--DECLARE @new_deaths  INT;
--DECLARE @new_cases INT;
--SET @new_deaths=12;
--SET @new_cases=0;
--select  sum(new_deaths) as GTotal_Death, sum(new_cases) as GTotal_Cases,  
--CASE 
--WHEN sum(new_cases) = 0 
--then NULL 
--ELSE (sum(new_deaths)/sum(new_cases))*100
--END AS GDeathPercent
--from PROJECTPORTFOLIO..COVIDDEATH
----where location like '%Nigeria%'
--where continent is not null
----group by date
--order by 1,2

---LOOKING AT Total population vs vaccinations

--select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
--sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
--from PROJECTPORTFOLIO..COVIDDEATH DEA
--join PROJECTPORTFOLIO..COVIDVACINATION  VACC
--    on DEA.location = VACC.location
--	and DEA.date = VACC.date
--	where dea.continent is not null
--	order by 2, 3

--CREATING CTE

WITH POPvsVAC (continent, location, date, population, New_Vaccinations, RollingSumOfPeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
from PROJECTPORTFOLIO..COVIDDEATH DEA
join PROJECTPORTFOLIO..COVIDVACINATION  VACC
    on DEA.location = VACC.location
	and DEA.date = VACC.date
	where dea.continent is not null
	--order by 2, 3
	)
	select *, (RollingSumOfPeopleVaccinated/population)*100 AS RollingPercentage
	from POPvsVAC


	--CREATE TEMPTABLE
DROP TABLE IF EXISTS #VaccinationPercentagee
CREATE TABLE #VaccinationPercentagee
	(continent varchar(255),
	location varchar(255),
	date datetime,
	population int,
	New_vaccinations int,
	RollingSumOfPeopleVaccinated bigint
	)
insert into #VaccinationPercentagee
	select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
    from PROJECTPORTFOLIO..COVIDDEATH DEA
    join PROJECTPORTFOLIO..COVIDVACINATION  VACC
    on DEA.location = VACC.location
	and DEA.date = VACC.date
	where dea.continent is not null
	--order by 2, 3
select *, (RollingSumOfPeopleVaccinated/population)*100 AS RollingPercentage
	from #VaccinationPercentagee

	--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION
	
	use PROJECTPORTFOLIO
	go
	CREATE VIEW VaccinationPercentage as
	select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
    from PROJECTPORTFOLIO..COVIDDEATH DEA
    join PROJECTPORTFOLIO..COVIDVACINATION  VACC
    on DEA.location = VACC.location
	and DEA.date = VACC.date
	where dea.continent is not null
	--order by 2, 3

	drop view if exists GLOBALNUMBERS
	Use PROJECTPORTFOLIO
	GO
	CREATE VIEW GLOBALNUMBERS AS
--DECLARE @new_deaths  INT;
--DECLARE @new_cases INT;
--SET @new_deaths=12;
--SET @new_cases=0;
select date, sum(new_deaths) as GTotal_Death, sum(new_cases) as GTotal_Cases,  
CASE 
WHEN sum(new_cases) = 0 
then NULL 
ELSE (sum(new_deaths)/sum(new_cases))*100
END AS GDeathPercent
from PROJECTPORTFOLIO..COVIDDEATH
--where location like '%Nigeria%'
where continent is not null
group by date
--order by 1,2

DROP VIEW IF EXISTS BYCONTINENT
USE PROJECTPORTFOLIO
GO
CREATE VIEW BYCONTINENT AS
select continent, max(cast(total_deaths as int)) as Deathperpopulation
from PROJECTPORTFOLIO..COVIDDEATH
--where location like '%Nigeria%'
where continent is not null
group by continent
--order by Deathperpopulation desc

