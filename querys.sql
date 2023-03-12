/*Autores: 
    Nestor Gonzalez 16-10455
    Jesus Bandez 17-10046

Queries que responden a las preguntas pedidas en el enunciado
*/

------------------ Pregunta 1
-- Se puede decir que todos son iguales a excepcion de los primeros valores si
-- estos se ven ordenados por fecha de forma ascendente.
-- Esto se debe a que el query calcula esos primeros valores mientras que
-- los datos que nos dan deciden dejarlos como null o 0
SELECT representante_iso_code,
	new_cases,
	new_cases_smoothed,
	AVG(new_cases) OVER 
        (PARTITION BY representante_iso_code 
         ORDER BY date_id 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
         ) AS new_cases_smoothed_calculado
FROM data_obtained;


-------------- Pregunta 2
WITH half_cases AS (
	SELECT representante_iso_code, max(total_cases)/2 AS half_total_cases FROM data_obtained
	JOIN Pais ON Pais.iso_code = data_obtained.representante_iso_code
	GROUP BY representante_iso_code
),
    representante_minimo AS(
	SELECT representante_iso_code, min(total_cases) AS cases FROM data_obtained
		WHERE total_cases >= (
			SELECT half_total_cases FROM half_cases
			WHERE half_cases.representante_iso_code = data_obtained.representante_iso_code
			)
	GROUP BY representante_iso_code
		)

SELECT representante_minimo.representante_iso_code, representante.name, MIN(date_id) FROM representante_minimo
JOIN data_obtained 
	ON data_obtained.representante_iso_code = representante_minimo.representante_iso_code 
	AND data_obtained.total_cases = representante_minimo.cases
JOIN representante ON representante.iso_code = representante_minimo.representante_iso_code
GROUP BY representante_minimo.representante_iso_code, representante.name;


--------Pregunta 3
WITH before_66_percent AS (
  SELECT representante_iso_code AS iso_code, date_id, population
  FROM Data_obtained d
  JOIN Representante r ON d.representante_iso_code = r.iso_code
  JOIN Pais p ON p.iso_code = r.iso_code
  WHERE people_vaccinated < population*66.666/100
  ORDER BY representante_iso_code, date_id DESC
),
 after_66_percent AS (
  SELECT representante_iso_code AS iso_code, date_id, population
  FROM Data_obtained d
  JOIN Representante r ON d.representante_iso_code = r.iso_code
  JOIN Pais p ON p.iso_code = r.iso_code
  WHERE people_vaccinated >= population*66.666/100
  ORDER BY representante_iso_code, date_id DESC
 ),
  before_66_deaths AS (
	 SELECT b66.iso_code, max(total_deaths) AS deaths FROM before_66_percent AS b66
	 JOIN Data_obtained AS d ON 
		d.representante_iso_code = b66.iso_code
		AND d.date_id = b66.date_id
	 GROUP BY b66.iso_code
 ),
  after_66_deaths AS (
	 SELECT a66.iso_code, max(d.total_deaths)-deaths AS deaths FROM after_66_percent AS a66
	 JOIN Data_obtained AS d ON 
		d.representante_iso_code = a66.iso_code
		AND d.date_id = a66.date_id
	 JOIN before_66_deaths AS b66 ON b66.iso_code = a66.iso_code
	 GROUP BY a66.iso_code, b66.deaths
 	 ORDER BY a66.iso_code
 ),
 before_66_days AS (
	 SELECT iso_code, max(b66.date_id)-min(b66.date_id)+1 AS days FROM before_66_percent AS b66
	 GROUP BY iso_code
),
 after_66_days AS (
	 SELECT iso_code, max(a66.date_id)-min(a66.date_id)+1 AS days FROM after_66_percent AS a66
	 GROUP BY iso_code
),
 before_66_death_rate AS (
 	SELECT b66d.iso_code, b66d.deaths/before_66_days.days AS death_rate_per_day FROM before_66_deaths AS b66d
	JOIN before_66_days ON before_66_days.iso_code = b66d.iso_code
 ),
  after_66_death_rate AS (
 	SELECT a66d.iso_code, a66d.deaths/after_66_days.days AS death_rate_per_day FROM after_66_deaths AS a66d
	JOIN after_66_days ON after_66_days.iso_code = a66d.iso_code
 )
 
SELECT b66d.iso_code, 
		b66d.death_rate_per_day AS death_rate_per_day_before,
		a66d.death_rate_per_day AS death_rate_per_day_after
		FROM after_66_death_rate AS a66d
		full JOIN before_66_death_rate AS b66d ON b66d.iso_code = a66d.iso_code;


------- Pregunta 4
WITH half_deaths AS (
	SELECT representante_iso_code, max(total_deaths)/2 AS half_total_deaths FROM data_obtained
	JOIN Pais ON Pais.iso_code = data_obtained.representante_iso_code
	GROUP BY representante_iso_code
	),
    representante_fecha_half_deaths AS(
	SELECT representante_iso_code, min(total_deaths) AS deaths FROM data_obtained
		WHERE total_deaths >= (
			SELECT half_total_deaths FROM half_deaths
			WHERE half_deaths.representante_iso_code = data_obtained.representante_iso_code
			)
	GROUP BY representante_iso_code
		),
	half_deaths_dates AS (	
	SELECT representante_fecha_half_deaths.representante_iso_code, MIN(date_id) AS date_half_deaths
	FROM representante_fecha_half_deaths
	JOIN data_obtained 
		ON data_obtained.representante_iso_code = representante_fecha_half_deaths.representante_iso_code 
		AND data_obtained.total_deaths = representante_fecha_half_deaths.deaths
	JOIN representante ON representante.iso_code = representante_fecha_half_deaths.representante_iso_code
	GROUP BY representante_fecha_half_deaths.representante_iso_code
	)
	
	SELECT hdd.representante_iso_code, r.name, 
		d.people_fully_vaccinated/r.population * 100 AS vaccination_percentage
		FROM half_deaths_dates AS hdd
	JOIN data_obtained AS d 
		ON d.representante_iso_code = hdd.representante_iso_code
		AND d.date_id = hdd.date_half_deaths
	JOIN representante AS r
		ON r.iso_code = hdd.representante_iso_code;



----- Pregunta 5
WITH continent_cases AS (
	SELECT representante_iso_code, max(total_cases) AS max_cases FROM data_obtained
		JOIN continente ON continente.iso_code = representante_iso_code
		GROUP BY representante_iso_code
	)
	
SELECT representante_iso_code, max_cases/population AS grow_rate FROM continent_cases
JOIN Representante AS r ON r.iso_code =  representante_iso_code
ORDER BY grow_rate DESC;