# Architecture - User Journey Analytics Pipeline

This diagram presents the overall data flow from raw GA4 sources to the final export model, including staging, intermediate processing, and reference enrichment.

```mermaid
flowchart TD
  subgraph GA4 Raw Events
    A1[analytics_web.events_*]
    A2[analytics_app.events_*]
  end

  subgraph Staging Models
    S1[stg_web_events.sql]
    S2[stg_app_events.sql]
  end

  subgraph Intermediate Models
    I1[int_base_users_combined.sql]
    I2[int_ref_companies.sql]
  end

  subgraph Final Mart
    M1[mart_user_journey_export.sql]
  end

  A1 --> S1
  A2 --> S2
  S1 --> M1
  S2 --> M1
  I1 --> M1
  I2 --> M1
```

---

### Data Flow Summary

- **GA4 Web & App**: Raw event data ingested from GA4 export tables
- **Staging Layer**: Filters and aggregates key user interactions (sessions, claims, quotes…)
- **Intermediate Layer**: Combines user metadata and external references (companies)
- **Mart Layer**: Final export used for analysis or campaign targeting
