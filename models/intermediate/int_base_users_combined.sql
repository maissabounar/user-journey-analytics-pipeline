with ga4_users as (

  select
    event_date as event_day,
    
    -- Deduplicated user ID
    coalesce(
      user_id,
      last_value(
        (select coalesce(value.string_value, cast(value.int_value as string))
         from unnest(user_properties)
         where key = 'user_ref_id' and value is not null
        ) ignore nulls
      ) over (partition by user_pseudo_id order by event_timestamp)
    ) as user_ref_id,

    (select value.string_value from unnest(user_properties) where key = 'user_rcu') as user_rcu,
    (select value.string_value from unnest(user_properties) where key = 'contract_origin') as contract_origin,
    (select value.string_value from unnest(user_properties) where key = 'insurer') as insurer,
    (select value.string_value from unnest(user_properties) where key = 'local_entity') as local_entity,
    (select value.string_value from unnest(user_properties) where key = 'benefit_type') as benefit_type,
    (select value.string_value from unnest(user_properties) where key = 'delegation') as delegation,
    '0000' as company_id,
    'unknown' as company_name,
    (select value.string_value from unnest(user_properties) where key = 'contract_label') as contract_label,
    (select value.string_value from unnest(user_properties) where key = 'contract_segment') as contract_segment,
    (select value.string_value from unnest(user_properties) where key = 'contract_category') as contract_category,
    (select value.string_value from unnest(user_properties) where key = 'alert_claim') as alert_claim,
    (select value.string_value from unnest(user_properties) where key = 'alert_evolution') as alert_evolution,
    (select value.string_value from unnest(user_properties) where key = 'alert_message') as alert_message,
    (select value.string_value from unnest(user_properties) where key = 'age') as age

  from `project_anon.analytics_web.events_*`

  where _table_suffix between format_date('%Y%m%d', date_sub(current_date(), interval 7 day))
                          and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
)

select array_agg(u order by event_day desc limit 1)[ordinal(1)].*
from ga4_users u
where regexp_contains(user_ref_id, r'^[0-9]{8,9}$')
  and regexp_contains(contract_origin, r'^[a-zA-Z0-9]+$')
  and regexp_contains(insurer, r'^[a-zA-Z0-9]+$')
  and regexp_contains(local_entity, r'^[a-zA-Z0-9]+$')
  and regexp_contains(benefit_type, r'^[a-zA-Z0-9]+$')
  and regexp_contains(delegation, r'^[a-zA-Z0-9]+$')
group by user_ref_id
