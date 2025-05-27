# Mapping - User Events (Anonymized)

This document describes how raw user events have been anonymized and structured in the pipeline for both web and app sources.

---

## 📱 App Events Mapping (Firebase)

| Original Firebase Event Name       | Anonymized Field         | Description                                 |
|-----------------------------------|--------------------------|---------------------------------------------|
| session_start                     | session_events           | App launch or session start                 |
| quotation_sent                    | quotation_events         | A quote request submitted from the app      |
| claim_sent_standard               | claim_standard_events    | Standard claim submitted                    |
| claim_sent_special                | claim_special_events     | Special (SNR-type) claim submitted          |

---

## 🖥️ Web Events Mapping (GA4)

| Original GA4 Field / Param        | Anonymized Field         | Description                                 |
|-----------------------------------|--------------------------|---------------------------------------------|
| user_id                           | user_ref_id              | User identifier                             |
| ga_session_id                     | session_id               | Session identifier                          |
| form_submit                       | form_submit              | Event type for submitted forms              |
| form_label                        | action_label             | Label of the form (used to classify events) |
| 'payment_request' in form_label   | payment_request_events   | Standard payment request                    |
| 'quotation' in form_label         | quotation_events         | Quote submission                            |
| 'send_message' in form_label      | send_message_events      | Sending a message from contact form         |
| is_webview                        | is_webview               | Boolean indicating webview usage            |

---

## 📦 Common Dimensions

| Dimension Type       | Field Name          | Description                              |
|----------------------|---------------------|------------------------------------------|
| Date                 | event_day           | Event date (from `event_date`)           |
| Device type          | device_type         | Platform (web, Android, iOS...)          |
| User Pseudo ID       | user_pseudo_id      | Technical anonymous user ID              |
| Timestamp            | event_timestamp     | Event-level timestamp                    |

---

All business-sensitive terms and identifiers have been renamed for safe publication.
