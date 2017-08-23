class MoveTitleAndAbstractCardToAuthorsColumn < DataMigration
  RAKE_TASK_UP = 'data:migrate:move_title_and_abstract'.freeze
  RAKE_TASK_DOWN = 'data:migrate:move_title_and_abstract_back'.freeze
end
