Create Table Representante(
    iso_code varchar(255) PRIMARY KEY,
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
    population double precision,
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
    population double precision,
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
)

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