module JournalServices

  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      with_noisy_errors do
        task_types = TaskType.all
        task_types.each do |task_type|
          jtt = journal.journal_task_types.where(task_type_id: task_type.id).first_or_create
          jtt.role ||= Role.find_by(kind: task_type.default_role).try(:name)
          jtt.title ||= task_type.default_title
          jtt.save
        end
      end
    end
  end
end
