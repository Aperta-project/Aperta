module SalesforceServices
  # BillingSync is responsible for validating the details of a paper's
  # billing information from the perspective of what PLOS wants in Salesforce
  # and then sync'ing that information.
  class BillingSync < Sync
    delegate :billing_task, to: :@paper, allow_nil: true
    delegate :financial_disclosure_task, to: :@paper, allow_nil: true
    delegate :salesforce_manuscript_id, to: :@paper, allow_nil: true

    validates :paper, :billing_task, :financial_disclosure_task, presence: true
    validates :salesforce_api, presence: true
    validates :salesforce_manuscript_id, presence: true

    attr_accessor :paper, :salesforce_api

    def initialize(paper:, salesforce_api: SalesforceServices::API)
      @paper = paper
      @salesforce_api = salesforce_api
    end

    # Syncs the paper's billing information to Salesforce if the sync is valid.
    # Otherwise, raises a SyncInvalid error.
    def sync!
      if valid?
        @salesforce_api.ensure_pfa_case(paper: @paper)
      else
        fail SyncInvalid, sync_invalid_message
      end
    end

    private

    def sync_invalid_message
      <<-MESSAGE.strip_heredoc
        The paper's billing information cannot be sent to Salesforce because it
        has missing or invalid information:

        #{errors.full_messages.join("\n")}

        The paper was: #{@paper.inspect}
        The billing task was: #{billing_task.inspect}
        The financial disclosure task was: #{financial_disclosure_task.inspect}
      MESSAGE
    end
  end
end
