with date_range as (
  select
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as start_date,
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as end_date
)

select
  event_date as event_day,
  ifnull(
    user_id,
    (select coalesce(value.string_value, cast(value.int_value as string))
     from unnest(user_properties) 
     where key = 'id_customer' and value is not null)
  ) as customer_id,

  count(distinct concat(user_pseudo_id, 
    (select value.int_value from unnest(event_params) where key = 'ga_session_id'))
  ) as sessions,

  (select value.string_value 
   from unnest(user_properties) where key = 'is_webview') as is_webview,

  -- Interaction: Payment request
  count(distinct case when lower(event_name) = 'form_submit'
    and regexp_contains(lower((select value.string_value from unnest(event_params) where key = 'form_label')), 'payment_request')
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as payment_request_events,

  -- Interaction: Quotation
  count(distinct case when lower(event_name) = 'form_submit'
    and regexp_contains(lower((select value.string_value from unnest(event_params) where key = 'form_label')), 'quotation')
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as quotation_events,

  -- Interaction: Send message
  count(distinct case when lower(event_name) = 'form_submit'
    and regexp_contains(lower((select value.string_value from unnest(event_params) where key = 'form_label')), 'send_message')
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as send_message_events

from 
  `project_id.analytics_web.events_*` as events,
  date_range

where
  _table_suffix between date_range.start_date and date_range.end_date

group by 1, 2, 4

