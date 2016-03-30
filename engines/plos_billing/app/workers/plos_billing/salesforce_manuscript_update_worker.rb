module PlosBilling
  # Async worker for SFDC manuscript updates
  class SalesforceManuscriptUpdateWorker
    include Sidekiq::Worker

    # 10 retries is approximately 2 ~ 3 hours. See
    # https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry
    # for retry formula
    sidekiq_options retry: 10
    sidekiq_retries_exhausted { |msg| email_admin_on_sidekiq_error(msg) }

    def self.email_admin_on_sidekiq_error(msg)
      error_message = <<-ERROR.strip_heredoc.chomp
        Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}
      ERROR
      paper_id = msg['args'][0]
      email_admin_error(paper_id, error_message)
    end

    def self.email_admin_error(paper_id, error_message)
      BillingSalesforceMailer
        .delay
        .notify_journal_admin_sfdc_error(paper_id, error_message)
    end

    def perform(paper_id)
      paper = ::Paper.find(paper_id)
      SalesforceServices.sync_paper!(paper)
    rescue ActiveRecord::RecordNotFound => ex
      message = record_not_found_error_message(ex, paper_id: paper_id)
      logger.error message
    rescue SalesforceServices::SyncInvalid => ex
      message = sync_invalid_error_message(ex, paper_id: paper_id)
      logger.error message
      self.class.email_admin_error(paper_id, message)
    end

    private

    def record_not_found_error_message(ex, paper_id:)
      <<-MESSAGE.strip_heredoc
        #{self.class.name}#perform failed because the Paper with id=#{paper_id}
        does not exist. The paper was likely deleted before this job ran.

        Original error: #{ex.message}
        Backtrace: #{ex.backtrace.join("\n")}
      MESSAGE
    end

    def sync_invalid_error_message(ex, paper_id:)
      <<-MESSAGE.strip_heredoc
        #{self.class.name}#perform failed due to an #{ex.class} being raised
        while trying to sync Paper with id=#{paper_id}

        Original error: #{ex.message}
        Backtrace: #{ex.backtrace.join("\n")}
      MESSAGE
    end
  end
end
