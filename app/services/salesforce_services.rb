# Module for interacting with Salesforce
module SalesforceServices
  class Error < ::StandardError; end
  class SyncInvalid < Error; end

  # Only send data to Salesforce if the author is
  # requesting publication fee assistance.
  def self.sync_paper!(paper, logger: Rails.logger)
    SalesforceServices::PaperSync.sync!(paper: paper)
    logger.info "Salesforce: Paper #{paper.id} sync'd successfully"

    answer = paper.answer_for('plos_billing--payment_method')
    should_send_billing_to_salesforce = answer.try(:value) == "pfa"

    if should_send_billing_to_salesforce
      SalesforceServices::BillingSync.sync!(paper: paper)
      logger.info(
        "Salesforce: Billing info on Paper #{paper.id} sync'd successfully"
      )
    else
      logger.info(
        "Salesforce: Paper #{paper.id} is not PFA, skipping billing sync."
      )
    end
  end
end
