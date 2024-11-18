{{ config(materialized='view') }}
with base as (
    select
        id as country_id,              
        population,                    
        area                 
    from country_info
    where population is not null       
)

select * from base
