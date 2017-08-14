module JournalServices
  # CreateDefaultTaskTypes is called by the 'data:update_journal_task_types'
  # migration which is run on every deploy. It ensures that every Task in the
  # system has an associated JournalTaskType in the database
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      Rails.logger.info "Processing journal: #{journal.name}..."
      with_noisy_errors do
        Task.descendants.each do |klass|
          jtt = journal.journal_task_types.find_or_initialize_by(kind: klass)
          jtt.title = klass::DEFAULT_TITLE
          jtt.role_hint = klass::DEFAULT_ROLE_HINT
          jtt.system_generated = klass::SYSTEM_GENERATED
          jtt.save!
        end
      end
    end
  end
end
