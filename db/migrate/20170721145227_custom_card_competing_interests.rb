class CustomCardCompetingInterests < DataMigration
  RAKE_TASK_UP = 'custom_card:convert_legacy_task'.freeze

  with_args "TahiStandardTasks::CompetingInterestsTask", "Competing Interests"
end
