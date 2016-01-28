module JournalServices
  # This service class will allow update all the tasks old_role and title attrs
  # to their default values defined in the task class, except for Ad-hoc tasks
  # TaskType.types keeps a reference of all the task registered.
  class UpdateDefaultTasks < BaseService
    def self.call
      TaskType.types.each do |klass, defaults|
        next if klass == 'Task'
        klass.constantize.update_all old_role: defaults[:default_role],
                                     title: defaults[:default_title]
      end
    end
  end
end
