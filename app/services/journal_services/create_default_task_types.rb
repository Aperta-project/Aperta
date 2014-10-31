module JournalServices

  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      with_noisy_errors do
        TaskType.types.each do |task_klass, details|
          jtt = journal.journal_task_types.where(kind: task_klass).first_or_create
          jtt.role ||= details[:default_role]
          jtt.title ||= details[:default_title]
          jtt.save
        end
      end
    end
  end
end
