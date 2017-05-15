class BiologyPdfSupport < DataMigration
  RAKE_TASK_UP = 'data:migrate:turn_on_pdf_support_for_biology'
  RAKE_TASK_DOWN = 'data:migrate:turn_off_pdf_support_for_biology'
end
