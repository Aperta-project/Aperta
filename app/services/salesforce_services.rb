# Module for interacting with Salesforce
module SalesforceServices
  class BillingCardMissing < StandardError; end
  class BillingFundingSourceMissing < StandardError; end

  # Only send data to Salesforce if the author is
  # requesting publication fee assistance.
  def self.send_to_salesforce?(paper:)
    fail BillingCardMissing unless paper.billing_task
    answer = paper.billing_task.answer_for("plos_billing--payment_method")
    fail BillingFundingSourceMissing unless answer
    answer.value == "pfa"
  end
end
