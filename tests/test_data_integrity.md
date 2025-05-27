# Data Integrity Checks

## Not null values
- `customer_id` in `stg_app_events`
- `customer_id` in `stg_web_events`

## Unique identifiers
- Combination of `customer_id + event_day` in final mart should be unique.

## Referential integrity
- Join between user tables and ref_companies must not produce orphan records.
