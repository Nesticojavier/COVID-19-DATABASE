/*
drop table if exists Data_obtained;
drop table if exists Pais;
drop table if exists Continente;
drop table if exists Grupo;
drop table if exists Mundo;
drop table if exists Representante;
drop table if exists date;


Create Table Representante(
    iso_code varchar(255) PRIMARY KEY,
	name varchar(255),
    population double precision
);

Create Table Grupo(
    iso_code varchar(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Continente(
    iso_code varchar(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);


Create Table Pais(
	iso_code varchar(255) PRIMARY KEY,
    iso_code_contienente varchar(255) REFERENCES Continente (iso_code),
    --population double precision,
    population_density double precision,
    median_age double precision ,
    aged_65_older double precision,
    aged_70_older double precision,
    gdp_per_capita double precision ,
    extreme_poverty double precision ,
    cardiovasc_death_rate double precision ,
    diabetes_prevalence double precision ,
    female_smokers double precision ,
    male_smokers double precision ,
    handwashing_facilities double precision ,
    hospital_beds_per_thousand double precision ,
    life_expectancy double precision ,
    human_development_index double precision ,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Mundo(
    iso_code varchar(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code),
    --population double precision,
    population_density double precision ,
    median_age double precision ,
    aged_65_older double precision ,
    aged_70_older double precision ,
    gdp_per_capita double precision ,
    extreme_poverty double precision ,
    cardiovasc_death_rate double precision ,
    diabetes_prevalence double precision ,
    female_smokers double precision ,
    male_smokers double precision ,
    handwashing_facilities double precision ,
    hospital_beds_per_thousand double precision ,
    life_expectancy double precision ,
    human_development_index double precision ,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Date(
    date date,
    Primary Key(date)
);

Create Table Data_obtained (
    representante_iso_code varchar(255),
    date_id date,

    stringency_index double precision,
    reproduction_rate double precision,

    total_cases double precision,
    new_cases double precision,
    new_cases_smoothed double precision,
    total_cases_per_million double precision,
    new_cases_per_million double precision,
    new_cases_smoothed_per_million double precision,

    total_deaths double precision,
    new_deaths double precision,
    new_deaths_smoothed double precision,
    total_deaths_per_million double precision,
    new_deaths_per_million double precision,
    new_deaths_smoothed_per_million double precision,

    icu_patients double precision,
    icu_patients_per_million double precision,
    hosp_patients double precision,
    hosp_patients_per_million double precision,
    weekly_icu_admissions double precision,
    weekly_icu_admissions_per_million double precision,
    weekly_hosp_admissions double precision,
    weekly_hosp_admissions_per_million double precision,    

    total_tests double precision,
    new_tests double precision,
    total_tests_per_thousand double precision,
    new_tests_per_thousand double precision,
    new_tests_smoothed double precision,
    new_tests_smoothed_per_thousand double precision,
    positive_rate double precision,
    tests_per_case double precision,
    tests_units varchar(255),

    total_vaccinations double precision,
    people_vaccinated double precision,
    people_fully_vaccinated double precision,
    total_boosters double precision,
    new_vaccinations double precision,
    new_vaccinations_smoothed double precision,
    total_vaccinations_per_hundred double precision,
    people_vaccinated_per_hundred double precision,
    people_fully_vaccinated_per_hundred double precision,
    total_boosters_per_hundred double precision,
    new_vaccinations_smoothed_per_million double precision,
    new_people_vaccinated_smoothed double precision,
    new_people_vaccinated_smoothed_per_hundred double precision,

    excess_mortality double precision,
    excess_mortality_cumulative double precision,
    excess_mortality_cumulative_absolute double precision,
    excess_mortality_cumulative_per_million double precision,

    Primary Key (representante_iso_code, date_id),
    FOREIGN KEY (representante_iso_code) REFERENCES  Representante (iso_code),
    FOREIGN KEY (date_id) REFERENCES  Date (date)
);

*/

Delete From Pais;
Delete From Continente;
Delete From Grupo;
Delete From Mundo;
Delete From Representante;

-- Insertar a todos los representantes
insert into Representante(iso_code, name, population)
select iso_code, location, population from covid_data
group by iso_code, location, population;

-- Insertar los continentes
with continents_name as (
select continent as name from covid_data
where continent is not NULL
group by continent
)
insert into Continente(iso_code)
select representante.iso_code from continents_name
join representante on representante.name = continents_name.name;

--- Insertar los paises
-- Codigo de continente con su nombre
with all_continents as (
	select Continente.iso_code, Representante.name from  Continente
	join Representante on Representante.iso_code=Continente.iso_code	
),

	 continent_contry_codes as (
    select all_continents.iso_code as continent_isocode, covid_data.iso_code as country_isocode,
            covid_data.population_density, covid_data.median_age, 
            covid_data.aged_65_older, covid_data.aged_70_older, covid_data.gdp_per_capita, 
            covid_data.extreme_poverty, covid_data.cardiovasc_death_rate, covid_data.diabetes_prevalence, 
            covid_data.female_smokers, covid_data.male_smokers, covid_data.handwashing_facilities,
            covid_data.hospital_beds_per_thousand, covid_data.life_expectancy, covid_data.human_development_index
    from covid_data
    join all_continents on all_continents.name = covid_data.continent
    where continent is not null
    group by all_continents.iso_code, covid_data.iso_code,
            covid_data.population_density, covid_data.median_age, 
            covid_data.aged_65_older, covid_data.aged_70_older, covid_data.gdp_per_capita, 
            covid_data.extreme_poverty, covid_data.cardiovasc_death_rate, covid_data.diabetes_prevalence, 
            covid_data.female_smokers, covid_data.male_smokers, covid_data.handwashing_facilities,
            covid_data.hospital_beds_per_thousand, covid_data.life_expectancy, covid_data.human_development_index
)

insert into pais(iso_code, iso_code_contienente, population_density, median_age, 
    aged_65_older, aged_70_older, gdp_per_capita, 
    extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
    female_smokers, male_smokers, handwashing_facilities,
    hospital_beds_per_thousand, life_expectancy, human_development_index)
select country_isocode, continent_isocode,
       population_density, median_age, 
       aged_65_older, aged_70_older, gdp_per_capita, 
       extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
       female_smokers, male_smokers, handwashing_facilities,
       hospital_beds_per_thousand, life_expectancy, human_development_index
from continent_contry_codes;

Select * From covid_data
Where iso_code = 'GRL'

--- Insertar al mundo
INSERT INTO Mundo(iso_code, population_density, median_age, 
aged_65_older, aged_70_older, gdp_per_capita, 
extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
female_smokers, male_smokers, handwashing_facilities,
hospital_beds_per_thousand, life_expectancy, human_development_index)
Select iso_code, population_density, median_age, 
aged_65_older, aged_70_older, gdp_per_capita, 
extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
female_smokers, male_smokers, handwashing_facilities,
hospital_beds_per_thousand, life_expectancy, human_development_index
From covid_data
Where iso_code = 'OWID_WRL'
Group by iso_code, population_density, median_age, 
aged_65_older, aged_70_older, gdp_per_capita, 
extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
female_smokers, male_smokers, handwashing_facilities,
hospital_beds_per_thousand, life_expectancy, human_development_index;

--- Insertar al resto de grupos
with group_isocodes as (
	select iso_code from Representante
	except	(
	select iso_code from Pais
	union
	select iso_code from Continente
	union
	select iso_code from Mundo)
)
insert into grupo(iso_code)
select iso_code from  group_isocodes;

--- Insertar las fechas
insert into Date(date)
select date from covid_data
group by date;

-- Relacionar los representates con sus datos y la fecha

with representante_fecha as (
	select iso_code, date from covid_data
	group by date, iso_code
	)

insert into Data_obtained(representante_iso_code, date_id, stringency_index, 
	reproduction_rate, total_cases, new_cases, new_cases_smoothed, total_cases_per_million,
    new_cases_per_million, new_cases_smoothed_per_million, total_deaths, new_deaths, new_deaths_smoothed,
    total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million,
    icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million,
    weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions,
    weekly_hosp_admissions_per_million, total_tests, new_tests, total_tests_per_thousand,
    new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate,
    tests_per_case, tests_units, total_vaccinations, people_vaccinated, people_fully_vaccinated,
    total_boosters, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred,
    people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred, total_boosters_per_hundred,
    new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed, new_people_vaccinated_smoothed_per_hundred,
    excess_mortality, excess_mortality_cumulative, excess_mortality_cumulative_absolute, excess_mortality_cumulative_per_million
)
select iso_code, date, stringency_index, reproduction_rate, total_cases, new_cases, new_cases_smoothed, total_cases_per_million,
    new_cases_per_million, new_cases_smoothed_per_million, total_deaths, new_deaths, new_deaths_smoothed,
    total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million,
    icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million,
    weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions,
    weekly_hosp_admissions_per_million, total_tests, new_tests, total_tests_per_thousand,
    new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate,
    tests_per_case, tests_units, total_vaccinations, people_vaccinated, people_fully_vaccinated,
    total_boosters, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred,
    people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred, total_boosters_per_hundred,
    new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed, new_people_vaccinated_smoothed_per_hundred,
    excess_mortality, excess_mortality_cumulative, excess_mortality_cumulative_absolute, excess_mortality_cumulative_per_million 
    from representante_fecha
natural join covid_data;
