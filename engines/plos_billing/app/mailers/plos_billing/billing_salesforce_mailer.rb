module PlosBilling
  # Mailer related to SFDC transactions
  class BillingSalesforceMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_site_admins_of_syncing_error(paper_id, message)
      @paper = ::Paper.find(paper_id)
      site_admin_emails = Role.site_admin_role.users.uniq.map(&:email).compact
      @message = message

      mail(to: site_admin_emails, subject: <<-SUBJECT.strip_heredoc)
        Action Required: Transmission to SalesForce failed for #{@paper.doi}
      SUBJECT
    end
  end
end
