{{ config(materialized='table') }}

with base as (
    select
        id as country_id,              -- Unique identifier for the country
        common_name,                   -- Common name of the country
        official_name,                 -- Official name of the country
        capital,                       -- Capital city
        region,                        -- Region of the country
        subregion,                     -- Subregion of the country
        languages::jsonb,              -- JSONB to handle multiple languages
        currency_code,                 -- Currency code
        currency_name,                 -- Currency name
        currency_symbol,               -- Currency symbol
        continents,                    -- Continents associated with the country
        created_at,                    -- When the record was created
        updated_at                     -- When the record was last updated
    from {{ ref('raw_country_data') }}  -- Refers to your raw country data table
)

select * from base;
