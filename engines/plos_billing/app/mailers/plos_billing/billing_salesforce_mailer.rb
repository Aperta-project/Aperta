module PlosBilling
  # Mailer related to SFDC transactions
  class BillingSalesforceMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_journal_admin_sfdc_error(paper_id, message)
      @paper = ::Paper.find(paper_id)
      journal_admin_emails = @paper.journal.admins.map(&:email).compact
      @message = message

      mail(to: journal_admin_emails, subject: <<-SUBJECT.strip_heredoc)
        Action Required: Transmission to SalesForce failed for #{@paper.doi}
      SUBJECT
    end
  end
end
