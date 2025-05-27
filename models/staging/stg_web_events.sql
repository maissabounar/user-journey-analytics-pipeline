-- models/staging/stg_web_events.sql

with date_range as (
  select
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as start_date,
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as end_date
)

select
  event_date as event_day,

  -- anonymized user identifier
  ifnull(user_id,
    (select coalesce(value.string_value, cast(value.int_value as string))
     from unnest(user_properties)
     where key = 'user_ext_id' and value is not null)
  ) as user_ref_id,

  platform as device_type,

  -- Session identifier
  count(distinct concat(user_pseudo_id, (select value.int_value 
                                         from unnest(event_params) 
                                         where key = 'session_id'))) as nb_sessions,

  -- Example of multiple tracked actions
  count(distinct case when lower((select value.string_value 
                                  from unnest(event_params) 
                                  where key = 'action_category')) = 'form' 
                          and lower((select value.string_value 
                                     from unnest(event_params) 
                                     where key = 'action_type')) = 'submit' 
                          and regexp_contains(lower((select value.string_value 
                                                     from unnest(event_params) 
                                                     where key = 'action_label')), 'quote')
                     then concat(user_pseudo_id, "-", cast(event_timestamp as string)) 
                end) as nb_quotes_submitted,

  count(distinct case when lower((select value.string_value 
                                  from unnest(event_params) 
                                  where key = 'action_category')) = 'form' 
                          and lower((select value.string_value 
                                     from unnest(event_params) 
                                     where key = 'action_type')) = 'submit' 
                          and regexp_contains(lower((select value.string_value 
                                                     from unnest(event_params) 
                                                     where key = 'action_label')), 'request_standard')
                     then concat(user_pseudo_id, "-", cast(event_timestamp as string)) 
                end) as nb_requests_std,

  count(distinct case when lower((select value.string_value 
                                  from unnest(event_params) 
                                  where key = 'action_category')) = 'form' 
                          and lower((select value.string_value 
                                     from unnest(event_params) 
                                     where key = 'action_type')) = 'submit' 
                          and regexp_contains(lower((select value.string_value 
                                                     from unnest(event_params) 
                                                     where key = 'action_label')), 'request_special')
                     then concat(user_pseudo_id, "-", cast(event_timestamp as string)) 
                end) as nb_requests_special

from 
  `project_anon.analytics_web.events_*` as events,
  date_range

where
  _table_suffix between date_range.start_date and date_range.end_date

group by 1, 2, 3

