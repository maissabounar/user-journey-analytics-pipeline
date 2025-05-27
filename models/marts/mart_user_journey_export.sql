with
app_events as (
  select * from {{ ref('stg_app_events') }}
),
web_events as (
  select * from {{ ref('stg_web_events') }}
),
user_profiles as (
  select * from {{ ref('int_base_users_combined') }}
),
company_mapping as (
  select * from {{ ref('int_ref_companies') }}
),
union_events as (
  select
    event_day,
    cast(user_ref_id as string) as user_ref_id,
    device_type,
    nb_sessions,
    quotation_events,
    claim_standard_events,
    claim_special_events,
    'app' as source

  from app_events

  union all

  select
    event_day,
    cast(user_ref_id as string) as user_ref_id,
    device_type,
    sessions as nb_sessions,
    quotation_events,
    payment_request_events as claim_standard_events,
    send_message_events as claim_special_events,
    'web' as source

  from web_events
),
visits_last_year as (
  select
    user_ref_id,
    source,
    sum(nb_sessions) as yearly_sessions
  from union_events
  where event_day >= format_date('%Y%m%d', date_sub(current_date(), interval 365 day))
  group by 1, 2
),
filtered_events as (
  select * from union_events
  where nb_sessions > 0
     or quotation_events > 0
     or claim_standard_events > 0
     or claim_special_events > 0
)

select
  format_date('%Y-%m-%d', parse_date('%Y%m%d', f.event_day)) as event_date,
  f.user_ref_id,
  u.contract_origin,
  u.insurer,
  u.local_entity,
  u.benefit_type,
  u.delegation,
  coalesce(c.company_id, '0000') as company_id,
  coalesce(c.company_name, 'unknown') as company_name,
  cast(u.age as int) as age,

  case
    when regexp_contains(lower(u.contract_category), 'group') then 'group'
    when regexp_contains(lower(u.contract_category), 'individual') then 'individual'
    else 'unknown'
  end as contract_category,

  f.source,
  f.device_type,
  coalesce(f.nb_sessions, 0) as nb_sessions,
  coalesce(f.quotation_events, 0) as nb_quotations,
  coalesce(f.claim_standard_events, 0) as nb_claims_standard,
  coalesce(f.claim_special_events, 0) as nb_claims_special,
  coalesce(v.yearly_sessions, 0) as sessions_last_12mo

from filtered_events f
inner join user_profiles u on f.user_ref_id = u.user_ref_id
left join visits_last_year v on f.user_ref_id = v.user_ref_id and f.source = v.source
left join company_mapping c on f.user_ref_id = c.user_ref_id
