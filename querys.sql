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
select representante_iso_code,
	new_cases,
	new_cases_smoothed,
	AVG(new_cases) over 
        (partition by representante_iso_code 
         order by date_id 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
         ) as new_cases_smoothed_calculado
from data_obtained;


-------------- Pregunta 2
with half_cases as (
	select representante_iso_code, max(total_cases)/2 as half_total_cases from data_obtained
	join Pais on Pais.iso_code = data_obtained.representante_iso_code
	group by representante_iso_code
),
    representante_minimo as(
	select representante_iso_code, min(total_cases) as cases from data_obtained
		where total_cases >= (
			select half_total_cases from half_cases
			where half_cases.representante_iso_code = data_obtained.representante_iso_code
			)
	group by representante_iso_code
		)

select representante_minimo.representante_iso_code, representante.name, MIN(date_id) from representante_minimo
join data_obtained 
	on data_obtained.representante_iso_code = representante_minimo.representante_iso_code 
	and data_obtained.total_cases = representante_minimo.cases
join representante on representante.iso_code = representante_minimo.representante_iso_code
group by representante_minimo.representante_iso_code, representante.name;


--------Pregunta 3
with before_66_percent as (
  Select representante_iso_code as iso_code, date_id, population
  From Data_obtained d
  Join Representante r On d.representante_iso_code = r.iso_code
  Join Pais p On p.iso_code = r.iso_code
  Where people_vaccinated < population*66.666/100
  Order By representante_iso_code, date_id desc
),
 after_66_percent as (
  Select representante_iso_code as iso_code, date_id, population
  From Data_obtained d
  Join Representante r On d.representante_iso_code = r.iso_code
  Join Pais p On p.iso_code = r.iso_code
  Where people_vaccinated >= population*66.666/100
  Order By representante_iso_code, date_id desc
 ),
  before_66_deaths as (
	 select b66.iso_code, max(total_deaths) as deaths from before_66_percent as b66
	 join Data_obtained as d on 
		d.representante_iso_code = b66.iso_code
		and d.date_id = b66.date_id
	 group by b66.iso_code
 ),
  after_66_deaths as (
	 select a66.iso_code, max(d.total_deaths)-deaths as deaths from after_66_percent as a66
	 join Data_obtained as d on 
		d.representante_iso_code = a66.iso_code
		and d.date_id = a66.date_id
	 join before_66_deaths as b66 on b66.iso_code = a66.iso_code
	 group by a66.iso_code, b66.deaths
 	 order by a66.iso_code
 ),
 before_66_days as (
	 select iso_code, max(b66.date_id)-min(b66.date_id)+1 as days from before_66_percent as b66
	 group by iso_code
),
 after_66_days as (
	 select iso_code, max(a66.date_id)-min(a66.date_id)+1 as days from after_66_percent as a66
	 group by iso_code
),
 before_66_death_rate as (
 	select b66d.iso_code, b66d.deaths/before_66_days.days as death_rate_per_day from before_66_deaths as b66d
	join before_66_days on before_66_days.iso_code = b66d.iso_code
 ),
  after_66_death_rate as (
 	select a66d.iso_code, a66d.deaths/after_66_days.days as death_rate_per_day from after_66_deaths as a66d
	join after_66_days on after_66_days.iso_code = a66d.iso_code
 )
 
select b66d.iso_code, 
		b66d.death_rate_per_day as death_rate_per_day_before,
		a66d.death_rate_per_day as death_rate_per_day_after
		from after_66_death_rate as a66d
		full join before_66_death_rate as b66d on b66d.iso_code = a66d.iso_code;


------- Pregunta 4
with half_deaths as (
	select representante_iso_code, max(total_deaths)/2 as half_total_deaths from data_obtained
	join Pais on Pais.iso_code = data_obtained.representante_iso_code
	group by representante_iso_code
	),
    representante_fecha_half_deaths as(
	select representante_iso_code, min(total_deaths) as deaths from data_obtained
		where total_deaths >= (
			select half_total_deaths from half_deaths
			where half_deaths.representante_iso_code = data_obtained.representante_iso_code
			)
	group by representante_iso_code
		),
	half_deaths_dates as (	
	select representante_fecha_half_deaths.representante_iso_code, MIN(date_id) as date_half_deaths
	from representante_fecha_half_deaths
	join data_obtained 
		on data_obtained.representante_iso_code = representante_fecha_half_deaths.representante_iso_code 
		and data_obtained.total_deaths = representante_fecha_half_deaths.deaths
	join representante on representante.iso_code = representante_fecha_half_deaths.representante_iso_code
	group by representante_fecha_half_deaths.representante_iso_code
	)
	
	select hdd.representante_iso_code, r.name, 
		d.people_fully_vaccinated/r.population * 100 as vaccination_percentage
		from half_deaths_dates as hdd
	join data_obtained as d 
		on d.representante_iso_code = hdd.representante_iso_code
		and d.date_id = hdd.date_half_deaths
	join representante as r
		on r.iso_code = hdd.representante_iso_code;



----- Pregunta 5
with continent_cases as (
	select representante_iso_code, max(total_cases) as max_cases from data_obtained
		join continente on continente.iso_code = representante_iso_code
		group by representante_iso_code
	)
	
select representante_iso_code, max_cases/population as grow_rate from continent_cases
join Representante as r on r.iso_code =  representante_iso_code
order by grow_rate DESC;