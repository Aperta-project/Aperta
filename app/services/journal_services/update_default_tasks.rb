module JournalServices
  # This service class will allow update all the tasks old_role and title attrs
  # to their default values defined in the task class, except for Ad-hoc tasks
  class UpdateDefaultTasks < BaseService
    def self.call
      Task.all_task_types.each do |klass|
        next if klass == Task
        klass.update_all old_role: klass::DEFAULT_ROLE,
                         title: klass::DEFAULT_TITLE
      end
    end
  end
end
