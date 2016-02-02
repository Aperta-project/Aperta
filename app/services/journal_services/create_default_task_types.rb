module JournalServices
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      Rails.logger.info "Processing journal: #{journal.name}..."
      with_noisy_errors do
        TaskType.types.each do |klass, details|
          jtt = journal.journal_task_types.find_or_initialize_by(kind: klass)
          jtt.title = details[:default_title]
          jtt.old_role = details[:default_role]
          jtt.required_permissions = details[:required_permissions]
          jtt.save!
        end
      end
    end
  end
end
