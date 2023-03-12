------------------ 1
select representante_iso_code,
	new_cases,
	new_cases_smoothed,
	AVG(new_cases) over 
        (partition by representante_iso_code 
         order by date_id 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
         ) as new_cases_smoothed_calculado
from data_obtained;




------------------2
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


--------4
with before_66_percent as (
  Select representante_iso_code, date_id, population
  From Data_obtained d
  Join Representante r On d.representante_iso_code = r.iso_code
  Join Pais p On p.iso_code = r.iso_code
  Where people_vaccinated < population*66.666/100
  Order By representante_iso_code, date_id
),
 after_66_percent as (
  Select representante_iso_code, date_id, population
  From Data_obtained d
  Join Representante r On d.representante_iso_code = r.iso_code
  Join Pais p On p.iso_code = r.iso_code
  Where people_vaccinated >= population*66.666/100
  Order By representante_iso_code, date_id
 ),
   death_rates_b66 as (
	 select distinct b66.representante_iso_code, 
		max(total_deaths) over (partition by b66.representante_iso_code) /r.population as death_rate_b66
	 from before_66_percent as b66
	 join Representante as r on  r.iso_code = b66.representante_iso_code
	 join data_obtained on data_obtained.representante_iso_code= b66.representante_iso_code 
		and data_obtained.date_id = b66.date_id
 ),
    death_rates_a66 as (
	 select distinct a66.representante_iso_code, 
		sum(new_deaths) over (partition by a66.representante_iso_code) /r.population as death_rate_a66
	 from after_66_percent as a66
	 join Representante as r on  r.iso_code = a66.representante_iso_code
	 join data_obtained on data_obtained.representante_iso_code= a66.representante_iso_code 
		and data_obtained.date_id = a66.date_id
 )
 

 
 select b66.representante_iso_code, death_rate_b66 as antes, death_rate_a66 as despues from death_rates_b66	as b66
	join death_rates_a66 on death_rates_a66.representante_iso_code = b66.representante_iso_code;


----- 5
with continent_cases as (
	select representante_iso_code, max(total_cases) as max_cases from data_obtained
		join continente on continente.iso_code = representante_iso_code
		group by representante_iso_code
	)
	
select representante_iso_code, max_cases/population as grow_rate from continent_cases
join Representante as r on r.iso_code =  representante_iso_code
order by grow_rate DESC