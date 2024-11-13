{{ config(materialized='table') }}
with base as (
    select
        id as country_id,              
        population,                    
        area,                          
        created_at                     
    from {{ ref('raw_country_data') }} 
    where population is not null       
)

select * from base;
