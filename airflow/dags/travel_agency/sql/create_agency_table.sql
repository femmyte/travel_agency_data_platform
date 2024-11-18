begin;
create table if not exists {{ params.schema }}.{{ params.table }} (
    id INTEGER IDENTITY(1,1),      -- Unique identifier for each record
    country_name VARCHAR(256),
    official_name VARCHAR(256),
    independent BOOLEAN,
    un_member BOOLEAN,
    start_of_week VARCHAR(200),
    capital VARCHAR(256),
    region VARCHAR(256),
    subregion VARCHAR(256),
    area FLOAT,
    population BIGINT,
    continents VARCHAR(256),
    currency_code VARCHAR(250),
    currency_name VARCHAR(256),
    currency_symbol VARCHAR(200),
    language VARCHAR(256),
    common_native_names VARCHAR(256),
    country_code VARCHAR(256)
);
end;