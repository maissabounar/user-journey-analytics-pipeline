with date_range as (
  select
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as start_date,
    format_date('%Y%m%d', date_sub(current_date(), interval 2 day)) as end_date
)

select
  event_date as event_day,
  (select value.string_value 
   from unnest(user_properties) 
   where key = "customer_id" and regexp_contains(value.string_value, r'^\d{8,9}$')
  ) as customer_id,

  platform as device_type,

  -- Connexions = session_start
  count(distinct case when event_name = 'session_start' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as session_events,

  -- Envoi devis
  count(distinct case when event_name = 'quotation_sent' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as quotation_events,

  -- Demande remboursement classique
  count(distinct case when event_name = 'claim_sent_standard' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as claim_standard_events,

  -- Demande remboursement SNR
  count(distinct case when event_name = 'claim_sent_special' 
    then concat(user_pseudo_id, "-", cast(event_timestamp as string)) end) as claim_special_events

from 
  `project_id.analytics_app.events_*` as events,
  date_range

where
  _table_suffix between date_range.start_date and date_range.end_date

group by 1, 2, 3
