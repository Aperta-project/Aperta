module JournalServices
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal, override_existing: false)
      Tahi.service_log.info "Creating/updating default task types for #{journal.name}..."
      with_noisy_errors do
        TaskType.types.each do |task_klass, details|
          jtt = journal.journal_task_types.find_or_initialize_by kind: task_klass
          if jtt.new_record? && !Rails.env.test?
            Tahi.service_log.info "Created #{task_klass} JournalTaskType"
          end
          if override_existing
            jtt.old_role = details[:default_role]
            jtt.title = details[:default_title]
            jtt.required_permission_action = details[:required_permission_action]
            jtt.required_permission_applies_to = details[:required_permission_applies_to]
          else
            jtt.old_role ||= details[:default_role]
            jtt.title ||= details[:default_title]
            jtt.required_permission_action ||= details[:required_permission_action]
            jtt.required_permission_applies_to ||= details[:required_permission_applies_to]
          end
          jtt.save!
        end
      end
    end
  end
end
