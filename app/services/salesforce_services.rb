# Module for interacting with Salesforce
module SalesforceServices
  class Error < ::StandardError; end
  class SyncInvalid < Error; end

  # Only send data to Salesforce if the author is
  # requesting publication fee assistance.
  def self.sync_paper!(paper, logger: Rails.logger)
    answer = paper.answer_for('plos_billing--payment_method')
    should_send_to_salesforce = answer.try(:value) == "pfa"

    if should_send_to_salesforce
      SalesforceServices::PaperSync.sync!(paper: paper)
      logger.info "Salesforce: Paper #{paper.id} sync'd successfully"

      SalesforceServices::BillingSync.sync!(paper: paper)
      logger.info "Salesforce: Billing info on Paper #{paper.id} sync'd successfully"
    else
      logger.info "Salesforce: Paper #{paper.id} is not PFA, skipping sync."
    end
  end
end
