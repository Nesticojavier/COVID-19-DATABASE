------------------ 1
select representante_iso_code,
	new_cases,
	new_cases_smoothed,
	AVG(new_cases) over 
        (partition by representante_iso_code 
         order by date_id 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
         ) as new_cases_smoothed_calculado
from data_obtained




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
group by representante_minimo.representante_iso_code, representante.name