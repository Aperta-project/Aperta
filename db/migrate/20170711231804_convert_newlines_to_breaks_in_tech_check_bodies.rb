class ConvertNewlinesToBreaksInTechCheckBodies < DataMigration
  RAKE_TASK_UP =
    'data:migrate:html_sanitization:convert_tech_check_bodies'.freeze
end
