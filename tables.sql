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

Delete From Continente;
Delete From Representante;

-- llenar tabla representante
INSERT INTO Representante(iso_code, name, population)
Select iso_code, location, population
From covid_data
Where continent is null
Group by iso_code, location, population;

-- lenar tabla continente 
INSERT INTO Continente(iso_code)
Select iso_code
From (Select iso_code, location, population
      From covid_data
      Where continent is null
      Group by iso_code, location, population) t1
Join (Select continent
      From covid_data
      Group by continent) t2
On t1.location = t2.continent;

-- llenar tabla de grupos
INSERT INTO Grupo(iso_code)
Select iso_code
From covid_data
Where continent is null 
      AND population is Not Null
	  AND location != 'World'
Group by iso_code, location, population
EXCEPT
Select iso_code
From (Select iso_code, location, population
      From covid_data
      Where continent is null
      Group by iso_code, location, population) t1
Join (Select continent
      From covid_data
      Group by continent) t2
On t1.location = t2.continent;


---------------------------------- Querys Jesus ----------------------
-- Insertar a todos los representantes
insert into Representante(iso_code, name, population)
select iso_code, location, population from file_data
group by iso_code, location, population

-- Insertar los continentes
with continents_name as (
select continent as name from file_data
where continent is not NULL
group by continent
)

insert into Continente(iso_code)
select representante.iso_code from continents_name
join representante on representante.name = continents_name.name

--- Insertar los paises
-- Codigo de continente con su nombre
with all_continents as (
	select Continente.iso_code, Representante.name from  Continente
	join Representante on Representante.iso_code=Continente.iso_code	
),

	 continent_contry_codes as (
select all_continents.iso_code as continent_isocode, file_data.iso_code as country_isocode from file_data
join all_continents on all_continents.name = file_data.continent
where continent is not null
group by all_continents.iso_code, file_data.iso_code
)
-- OJO: FALTA METERLE LOS OTROS DATOS A PAIS
insert into pais(iso_code, iso_code_contienente)
select country_isocode, continent_isocode from continent_contry_codes;

--- Insertar al mundo
-- OJO: Faltan los otros datos
insert into mundo(iso_code)
select iso_code from file_data
where iso_code = 'OWID_WRL'
group by iso_code

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
select iso_code from  group_isocodes