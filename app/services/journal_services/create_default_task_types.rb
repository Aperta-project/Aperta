module JournalServices
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      Rails.logger.info "Processing journal: #{journal.name}..."
      with_noisy_errors do
        Task.all_task_types.each do |klass|
          jtt = journal.journal_task_types.find_or_initialize_by(kind: klass)
          jtt.title = klass::DEFAULT_TITLE
          jtt.old_role = klass::DEFAULT_ROLE
          jtt.required_permissions = klass::REQUIRED_PERMISSIONS
          jtt.save!
        end
      end
    end
  end
end
