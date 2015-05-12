module JournalServices

  class CreateDefaultTaskTypes < BaseService
    def self.call(journal, override_existing: false)
      with_noisy_errors do
        TaskType.types.each do |task_klass, details|
          journal_task_type_scope = journal.journal_task_types.where(kind: task_klass)
          jtt = journal_task_type_scope.first.present? ? journal_task_type_scope.first : journal_task_type_scope.build
          if override_existing
            jtt.role = details[:default_role]
            jtt.title = details[:default_title]
          else
            jtt.role ||= details[:default_role]
            jtt.title ||= details[:default_title]
          end
          jtt.save!
        end
      end
    end
  end
end
