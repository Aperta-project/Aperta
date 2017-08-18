module JournalServices
  # This service class will allow update all the tasks' titles to their
  # default values defined in the task class, except for Ad-hoc tasks
  class UpdateDefaultTasks < BaseService
    def self.call
      (Task.descendants - [CustomCardTask]).each(&:restore_defaults)
    end
  end
end
