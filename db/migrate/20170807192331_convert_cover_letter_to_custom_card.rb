class ConvertCoverLetterToCustomCard < DataMigration
  RAKE_TASK_UP = 'custom_card:convert_legacy_task'.freeze

  with_args "TahiStandardTasks::CoverLetterTask", "Cover Letter"
end
