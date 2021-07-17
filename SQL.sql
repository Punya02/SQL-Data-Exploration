use [project 1]

--import data from excel

select * from covid_death;

select location,date,population, total_cases from covid_death 
order by total_cases desc;

select  distinct total_deaths ,continent ,location , date from covid_death;

select * from covid_death
where location = 'india'
order by 1,2;


select * from covid_death
where location = 'india'
and date like '%2021%'
or date like '%2020%'
order by 1,2;

-- total_cases vs total_death
select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where continent is not null
order by 1,2 desc;

select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where continent is not null
and location = 'india'
order by 1,2 desc;

--population vs total_cases
select  location, date,  population, total_cases, (total_cases/population)*100 as population_percentage
from covid_death
where location  like 'india'
order by 1,2 desc;


--countries with highest infection rate compare to polpuation
select  location, date,  population, max(total_cases) as highest_infection_count, 
max((total_cases/population))*100 as cases_percentage
from covid_death
--where location  like 'india'
--where continent is not null
group by location, date,  population
order by 1,2 desc;


--countries with highest death count per population
select  continent , location, population, max(cast(total_deaths as int)) as highest_death_count, 
max((total_deaths/population))*100 as death_percentage
from covid_death
where location  like 'india'
--where continent is not null
group by continent ,location, population
order by 1,2 desc;


--global numbers
select  location, population, sum(cast(total_cases as float)) as global_cases , sum(cast(total_deaths as float)) as global_death
from covid_death
group by location, population
order by 1,2 desc;

select  location, population, sum(cast(total_cases as float)) as global_cases , sum(cast(total_deaths as float)) as global_death
from covid_death
where location  like 'india'
group by location, population
order by 1,2 desc;

select  location, population, sum(cast(total_cases as float)) as global_cases , sum(cast(total_deaths as float)) as global_death
from covid_death
where total_cases  is null and total_deaths is null
group by location, population
order by 1,2 desc;


--global_cases vs global-death
select  location, population, 
        sum(cast(total_cases as float)) as global_cases , 
		sum(cast(total_deaths as float)) as global_death,
	    sum(cast(total_deaths as float)/cast(population as float))*100 as global_percentage
from covid_death
where location  like 'india'
group by location, population
order by 1,2 desc;

select  location, population, 
        sum(cast(total_cases as float)) as global_cases , 
		sum(cast(total_deaths as float)) as global_death,
	    sum(cast(total_deaths as float)/cast(population as float))*100 as global_percentage
from covid_death
where total_cases  is not null and total_deaths is not null
group by location, population
order by 1,2 desc;

select  date , sum(new_cases)
from covid_death
where location = 'india'
group by date
order by 1,2 desc ;

select  date , sum(cast(new_deaths as float))
from covid_death
where location = 'india'
group by date
order by 1,2 desc ;

select  date , sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,
               sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covid_death
where continent is not null
group by date
order by 1,2 desc ;


--overall death percentage
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,
               sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covid_death
where continent is not null
order by 1,2 desc ;



--vaccination--
select * from covid_vaccination

select * from covid_vaccination as vac
join covid_death as dea
on dea.location = vac.location
and dea.date = dea.date;

select dea.date , dea.location , dea.population, vac.new_vaccinations
       from covid_vaccination as vac
       join covid_death as dea
       on dea.location = vac.location
       and dea.date = dea.date
	   --where dea.location = 'india'
	   where vac.new_vaccinations is not null
	   order by 1,2;


select dea.date , dea.location , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over(partition by dea.location) as new
       from covid_vaccination as vac
       join covid_death as dea
       on dea.location = vac.location
       and dea.date = dea.date
	   --where dea.location = 'india'
	   where dea.continent is not null
	   order by  1,2 desc;

--use cte
with popvsvac (date , location , population, new_vaccinations,new)
as
(select dea.date , dea.location , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over(partition by dea.location) as new
       from covid_vaccination as vac
       join covid_death as dea
       on dea.location = vac.location
       and dea.date = dea.date
	   --where dea.location = 'india'
	   --where dea.continent is not null
	  -- order by 1,2 desc
)
select * , (new/population)*100 from popvsvac;


-- temp table
drop table if exists #percentage_population_report
create table #percentage_population_report
( 
date datetime,
location nvarchar,
population  numeric,
new_vaccinations numeric,
new  numeric
)

insert into  #percentage_population_report
select dea.date , dea.location , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over(partition by dea.location) as new
       from covid_vaccination as vac
       join covid_death as dea
       on dea.location = vac.location
       and dea.date = dea.date
	
select * , (new/population)*100 from #percentage_population_report;


--view

create view  percentage_population as
select dea.date , dea.location , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over(partition by dea.location) as new
       from covid_vaccination as vac
       join covid_death as dea
       on dea.location = vac.location
       and dea.date = dea.date
  where dea.continent is not null
