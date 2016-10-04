module JournalServices
  # This service class will allow update all the tasks old_role and title attrs
  # to their default values defined in the task class, except for Ad-hoc tasks
  class UpdateDefaultTasks < BaseService
    def self.call
      Task.descendants.each(&:restore_defaults)
    end
  end
end
