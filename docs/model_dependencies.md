# dbt Model Dependencies

```mermaid
graph LR
  stg_web_events --> mart_user_journey_export
  stg_app_events --> mart_user_journey_export
  int_base_users_combined --> mart_user_journey_export
  int_ref_companies --> mart_user_journey_export
```

---

This diagram illustrates how each dbt model feeds into the final `mart_user_journey_export.sql` model.
- **Staging models** prepare the raw GA4 data
- **Intermediate models** enrich user profiles and add company info
- **Final mart** combines everything for analytics and campaign readiness
