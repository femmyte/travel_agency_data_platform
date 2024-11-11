begin;
create table if not exists {{ params.schema }}.{{ params.table }} (
    id SERIAL PRIMARY KEY,           -- Unique identifier for each record
    common_name VARCHAR(100),        -- Common name of the country
    independent BOOLEAN,             -- Whether the country is independent
    un_member BOOLEAN,               -- Whether the country is a UN member
    start_of_week VARCHAR(10),       -- Day the week starts on (e.g., "Monday", "Sunday")
    official_name VARCHAR(150),      -- Official name of the country
    idd VARCHAR(10),                 -- International direct dialing code
    capital VARCHAR(100),            -- Capital city
    region VARCHAR(50),              -- Region (e.g., "Europe", "Africa")
    subregion VARCHAR(50),           -- Subregion (e.g., "Western Europe")
    languages JSON,                  -- List of official languages (JSON to handle multiple values)
    area NUMERIC,                    -- Area in square kilometers
    population BIGINT,               -- Population count
    currency_code CHAR(3),           -- ISO currency code (e.g., "USD", "EUR")
    currency_name VARCHAR(50),       -- Currency name
    currency_symbol VARCHAR(5),      -- Currency symbol (e.g., "$", "€")
    continents VARCHAR(50),          -- Continent(s) (e.g., "Europe", "Asia")
    created_at TIMESTAMP DEFAULT NOW(),  -- Timestamp for record creation
    updated_at TIMESTAMP DEFAULT NOW()
) sortkey(created_at);
end;