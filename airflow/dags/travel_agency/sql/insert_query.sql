begin;
insert into {{ params.schema }}.{{ params.table }}
  select
    listtime::date as date_key,
    count(distinct sellerid) as total_sellers,
    count(distinct eventid) as total_events,
    sum(numtickets) as total_tickets,
    sum(totalprice) as total_revenue
  from tickit.listing
  where listtime::date = '{{ ds }}'
  group by date_key
;
end;