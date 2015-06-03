module JournalServices
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal, override_existing: false)
      with_noisy_errors do
        TaskType.types.each do |task_klass, details|
          jtt = journal.journal_task_types.find_or_initialize_by kind: task_klass
          if jtt.new_record?
            Tahi.service_log.info "Created #{task_klass} JournalTaskType"
          end
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
