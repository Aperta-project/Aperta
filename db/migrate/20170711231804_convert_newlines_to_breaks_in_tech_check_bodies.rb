class ConvertNewlinesToBreaksInTechCheckBodies < DataMigration
  RAKE_TASK_UP =
    'data:migrate:sanitize_database_html:convert_tech_check_bodies'.freeze
end
