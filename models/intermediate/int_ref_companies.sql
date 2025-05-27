select
  cast(user_ref_id as string) as user_ref_id,
  cast(company_id as string) as company_id,
  coalesce(company_name, 'unknown') as company_name

from `project_anon.external_ref.user_company_mapping`

