/*Autores: 
    Nestor Gonzalez 16-10455
    Jesus Bandez 17-10046

Crear la tabla inicial y se importan todos los datos del
.csv a ella 
*/

Drop table file_data;

-- Crear tabla con el mismo formato donde se almacenaran los datos
Create Table covid_data(
    iso_code varchar(255),
    continent varchar(255),
    location varchar(255),
    date date,
    total_cases double precision,
    new_cases double precision,
    new_cases_smoothed double precision,
    total_deaths double precision,
    new_deaths double precision,
    new_deaths_smoothed double precision ,
    total_cases_per_million double precision ,
    new_cases_per_million double precision ,
    new_cases_smoothed_per_million double precision ,
    total_deaths_per_million double precision ,
    new_deaths_per_million double precision ,
    new_deaths_smoothed_per_million double precision ,
    reproduction_rate double precision ,
    icu_patients double precision ,
    icu_patients_per_million double precision ,
    hosp_patients double precision ,
    hosp_patients_per_million double precision ,
    weekly_icu_admissions double precision ,
    weekly_icu_admissions_per_million double precision ,
    weekly_hosp_admissions double precision ,
    weekly_hosp_admissions_per_million double precision ,
    total_tests double precision ,
    new_tests double precision ,
    total_tests_per_thousand double precision ,
    new_tests_per_thousand double precision ,
    new_tests_smoothed double precision ,
    new_tests_smoothed_per_thousand double precision ,
    positive_rate double precision ,
    tests_per_case double precision ,
    tests_units varchar(255) ,
    total_vaccinations double precision ,
    people_vaccinated double precision ,
    people_fully_vaccinated double precision ,
    total_boosters double precision ,
    new_vaccinations double precision ,
    new_vaccinations_smoothed double precision ,
    total_vaccinations_per_hundred double precision ,
    people_vaccinated_per_hundred double precision ,
    people_fully_vaccinated_per_hundred double precision ,
    total_boosters_per_hundred double precision ,
    new_vaccinations_smoothed_per_million double precision ,
    new_people_vaccinated_smoothed double precision ,
    new_people_vaccinated_smoothed_per_hundred double precision ,
    stringency_index double precision ,
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
    population double precision ,
    excess_mortality_cumulative_absolute double precision ,
    excess_mortality_cumulative double precision ,
    excess_mortality double precision ,
    excess_mortality_cumulative_per_million double precision
);

-- Importar datos en la tabla de sql creada
\copy covid_data from 'owid-covid-data.csv' with DELIMITER ',' CSV HEADER