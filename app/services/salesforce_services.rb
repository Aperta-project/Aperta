# Module for interacting with Salesforce
module SalesforceServices
  class Error < ::StandardError; end
  class SyncInvalid < Error; end

  # Only send data to Salesforce if the author is
  # requesting publication fee assistance.
  def self.sync_paper!(paper)
    answer = paper.answer_for('plos_billing--payment_method')
    should_send_to_salesforce = answer.try(:value) == "pfa"

    if should_send_to_salesforce
      SalesforceServices::PaperSync.sync!(paper: paper)
      SalesforceServices::BillingSync.sync!(paper: paper)
    end
  end
end
