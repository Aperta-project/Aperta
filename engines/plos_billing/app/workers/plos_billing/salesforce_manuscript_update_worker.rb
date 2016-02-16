module PlosBilling
  # Async worker for SFDC manuscript updates
  class SalesforceManuscriptUpdateWorker
    include Sidekiq::Worker

    # 14 retries is approximately one and a half days with the default
    # exponential backoff
    sidekiq_options retry: 14
    sidekiq_retries_exhausted { |msg| email_admin_on_error(msg) }

    def perform(paper_id)
      paper = ::Paper.find(paper_id)
      return unless paper.billing_card
      SalesforceServices::API.find_or_create_manuscript(paper_id: paper.id)
      SalesforceServices::API.create_billing_and_pfa_case(paper_id: paper.id)
    end

    def self.email_admin_on_error(msg)
      error_message = <<-ERROR.strip_heredoc
        Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}
      ERROR
      paper_id = msg['args'][0]
      BillingSalesforceMailer
        .delay
        .notify_journal_admin_sfdc_error(paper_id, error_message)
    end
  end
end
