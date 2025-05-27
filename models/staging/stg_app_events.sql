with date_range as (
  select
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as start_date,
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as end_date
)

select
  event_date as event_day,
  
  -- anonymized user identifier
  (select value.string_value 
   from unnest(user_properties) 
   where key = "user_ext_id" and regexp_contains(value.string_value, r'^\d{8,9}$')
  ) as user_ref_id,

  platform as device_type,

  -- Session start event
  count(distinct case when event_name = 'event_session_start' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as nb_sessions,

  -- Quote submission
  count(distinct case when event_name = 'event_submit_quote' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as nb_quotes_submitted,

  -- Standard request submission
  count(distinct case when event_name = 'event_submit_request_std' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as nb_requests_std,

  -- Special request submission
  count(distinct case when event_name = 'event_submit_request_special' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as nb_requests_special

from 
  `project_anon.analytics_mobile.events_*` as events,
  date_range

where
  _table_suffix between date_range.start_date and date_range.end_date

group by 1, 2, 3
