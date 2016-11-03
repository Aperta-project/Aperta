class AssociateCreatorAuthorsWithTheirUser < DataMigration
  RAKE_TASK_UP = 'data:migrate:authors:connect_creators_with_user_record'
  RAKE_TASK_DOWN = 'data:migrate:authors:disconnect_creators_from_user_record'
end
