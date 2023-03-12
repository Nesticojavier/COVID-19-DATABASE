
DROP TABLE IF EXISTS Data_obtained;
DROP TABLE IF EXISTS Pais;
DROP TABLE IF EXISTS Continente;
DROP TABLE IF EXISTS Grupo;
DROP TABLE IF EXISTS Mundo;
DROP TABLE IF EXISTS Representante;
DROP TABLE IF EXISTS date;


Create Table Representante(
    iso_code VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255),
    population DOUBLE PRECISION
);

Create Table Grupo(
    iso_code VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Continente(
    iso_code VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);


Create Table Pais(
	iso_code VARCHAR(255) PRIMARY KEY,
    iso_code_contienente VARCHAR(255) REFERENCES Continente (iso_code),    
    population_density DOUBLE PRECISION,
    median_age DOUBLE PRECISION ,
    aged_65_older DOUBLE PRECISION,
    aged_70_older DOUBLE PRECISION,
    gdp_per_capita DOUBLE PRECISION ,
    extreme_poverty DOUBLE PRECISION ,
    cardiovasc_death_rate DOUBLE PRECISION ,
    diabetes_prevalence DOUBLE PRECISION ,
    female_smokers DOUBLE PRECISION ,
    male_smokers DOUBLE PRECISION ,
    handwashing_facilities DOUBLE PRECISION ,
    hospital_beds_per_thousand DOUBLE PRECISION ,
    life_expectancy DOUBLE PRECISION ,
    human_development_index DOUBLE PRECISION ,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Mundo(
    iso_code VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code),    
    population_density DOUBLE PRECISION ,
    median_age DOUBLE PRECISION ,
    aged_65_older DOUBLE PRECISION ,
    aged_70_older DOUBLE PRECISION ,
    gdp_per_capita DOUBLE PRECISION ,
    extreme_poverty DOUBLE PRECISION ,
    cardiovasc_death_rate DOUBLE PRECISION ,
    diabetes_prevalence DOUBLE PRECISION ,
    female_smokers DOUBLE PRECISION ,
    male_smokers DOUBLE PRECISION ,
    handwashing_facilities DOUBLE PRECISION ,
    hospital_beds_per_thousand DOUBLE PRECISION ,
    life_expectancy DOUBLE PRECISION ,
    human_development_index DOUBLE PRECISION ,
    FOREIGN KEY (iso_code) REFERENCES Representante (iso_code)
);

Create Table Date(
    date DATE,
    Primary Key(date)
);

Create Table Data_obtained (
    representante_iso_code VARCHAR(255),
    date_id DATE,

    stringency_index DOUBLE PRECISION,
    reproduction_rate DOUBLE PRECISION,

    total_cases DOUBLE PRECISION,
    new_cases DOUBLE PRECISION,
    new_cases_smoothed DOUBLE PRECISION,
    total_cases_per_million DOUBLE PRECISION,
    new_cases_per_million DOUBLE PRECISION,
    new_cases_smoothed_per_million DOUBLE PRECISION,

    total_deaths DOUBLE PRECISION,
    new_deaths DOUBLE PRECISION,
    new_deaths_smoothed DOUBLE PRECISION,
    total_deaths_per_million DOUBLE PRECISION,
    new_deaths_per_million DOUBLE PRECISION,
    new_deaths_smoothed_per_million DOUBLE PRECISION,

    icu_patients DOUBLE PRECISION,
    icu_patients_per_million DOUBLE PRECISION,
    hosp_patients DOUBLE PRECISION,
    hosp_patients_per_million DOUBLE PRECISION,
    weekly_icu_admissions DOUBLE PRECISION,
    weekly_icu_admissions_per_million DOUBLE PRECISION,
    weekly_hosp_admissions DOUBLE PRECISION,
    weekly_hosp_admissions_per_million DOUBLE PRECISION,    

    total_tests DOUBLE PRECISION,
    new_tests DOUBLE PRECISION,
    total_tests_per_thousand DOUBLE PRECISION,
    new_tests_per_thousand DOUBLE PRECISION,
    new_tests_smoothed DOUBLE PRECISION,
    new_tests_smoothed_per_thousand DOUBLE PRECISION,
    positive_rate DOUBLE PRECISION,
    tests_per_case DOUBLE PRECISION,
    tests_units VARCHAR(255),

    total_vaccinations DOUBLE PRECISION,
    people_vaccinated DOUBLE PRECISION,
    people_fully_vaccinated DOUBLE PRECISION,
    total_boosters DOUBLE PRECISION,
    new_vaccinations DOUBLE PRECISION,
    new_vaccinations_smoothed DOUBLE PRECISION,
    total_vaccinations_per_hundred DOUBLE PRECISION,
    people_vaccinated_per_hundred DOUBLE PRECISION,
    people_fully_vaccinated_per_hundred DOUBLE PRECISION,
    total_boosters_per_hundred DOUBLE PRECISION,
    new_vaccinations_smoothed_per_million DOUBLE PRECISION,
    new_people_vaccinated_smoothed DOUBLE PRECISION,
    new_people_vaccinated_smoothed_per_hundred DOUBLE PRECISION,

    excess_mortality DOUBLE PRECISION,
    excess_mortality_cumulative DOUBLE PRECISION,
    excess_mortality_cumulative_absolute DOUBLE PRECISION,
    excess_mortality_cumulative_per_million DOUBLE PRECISION,

    Primary Key (representante_iso_code, date_id),
    FOREIGN KEY (representante_iso_code) REFERENCES  Representante (iso_code),
    FOREIGN KEY (date_id) REFERENCES  Date (date)
);



DELETE FROM Pais;
DELETE FROM Continente;
DELETE FROM Grupo;
DELETE FROM Mundo;
DELETE FROM Data_obtained;
DELETE FROM Representante;
DELETE FROM Date;

-- Insertar a todos los representantes
INSERT INTO Representante(iso_code, name, population)
SELECT iso_code, location, population FROM covid_data
GROUP BY iso_code, location, population;

-- Insertar los continentes
WITH continents_name AS (
SELECT continent AS name FROM covid_data
where continent IS NOT NULL
GROUP BY continent
)
INSERT INTO Continente(iso_code)
SELECT representante.iso_code FROM continents_name
JOIN representante ON representante.name = continents_name.name;

--- Insertar los paises
-- Codigo de continente con su nombre
WITH all_continents AS (
	SELECT Continente.iso_code, Representante.name FROM  Continente
	JOIN Representante ON Representante.iso_code=Continente.iso_code	
),

	 continent_contry_codes AS (
    SELECT all_continents.iso_code AS continent_isocode, covid_data.iso_code AS country_isocode,
            covid_data.population_density, covid_data.median_age, 
            covid_data.aged_65_older, covid_data.aged_70_older, covid_data.gdp_per_capita, 
            covid_data.extreme_poverty, covid_data.cardiovasc_death_rate, covid_data.diabetes_prevalence, 
            covid_data.female_smokers, covid_data.male_smokers, covid_data.handwashing_facilities,
            covid_data.hospital_beds_per_thousand, covid_data.life_expectancy, covid_data.human_development_index
    FROM covid_data
    JOIN all_continents ON all_continents.name = covid_data.continent
    where continent IS NOT null
    GROUP BY all_continents.iso_code, covid_data.iso_code,
            covid_data.population_density, covid_data.median_age, 
            covid_data.aged_65_older, covid_data.aged_70_older, covid_data.gdp_per_capita, 
            covid_data.extreme_poverty, covid_data.cardiovasc_death_rate, covid_data.diabetes_prevalence, 
            covid_data.female_smokers, covid_data.male_smokers, covid_data.handwashing_facilities,
            covid_data.hospital_beds_per_thousand, covid_data.life_expectancy, covid_data.human_development_index
)

INSERT INTO pais(iso_code, iso_code_contienente, population_density, median_age, 
    aged_65_older, aged_70_older, gdp_per_capita, 
    extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
    female_smokers, male_smokers, handwashing_facilities,
    hospital_beds_per_thousand, life_expectancy, human_development_index)
SELECT country_isocode, continent_isocode,
       population_density, median_age, 
       aged_65_older, aged_70_older, gdp_per_capita, 
       extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
       female_smokers, male_smokers, handwashing_facilities,
       hospital_beds_per_thousand, life_expectancy, human_development_index
FROM continent_contry_codes;

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
FROM covid_data
Where iso_code = 'OWID_WRL'
Group BY iso_code, population_density, median_age, 
aged_65_older, aged_70_older, gdp_per_capita, 
extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, 
female_smokers, male_smokers, handwashing_facilities,
hospital_beds_per_thousand, life_expectancy, human_development_index;

--- Insertar al resto de grupos
WITH group_isocodes AS (
	SELECT iso_code FROM Representante
	EXCEPT	(
	SELECT iso_code FROM Pais
	UNION
	SELECT iso_code FROM Continente
	UNION
	SELECT iso_code FROM Mundo)
)
INSERT INTO grupo(iso_code)
SELECT iso_code FROM  group_isocodes;

--- Insertar las fechas
INSERT INTO Date(date)
SELECT date FROM covid_data
GROUP BY date;

-- Relacionar los representates con sus datos y la fecha

WITH representante_fecha AS (
	SELECT iso_code, date FROM covid_data
	GROUP BY date, iso_code
	)

INSERT INTO Data_obtained(representante_iso_code, date_id, stringency_index, 
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
SELECT iso_code, date, stringency_index, reproduction_rate, total_cases, new_cases, new_cases_smoothed, total_cases_per_million,
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
    FROM representante_fecha
NATURAL JOIN covid_data;