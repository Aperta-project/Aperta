class AssignCardsToLegacyTasks < DataMigration
  RAKE_TASK_UP =
    'data:migrate:assign_card_version_to_all_tasks'.freeze
end
