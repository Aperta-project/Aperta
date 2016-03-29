module SalesforceServices
  # PaperSync is responsible for validating the details of a paper's
  # information from the perspective of what PLOS wants in Salesforce.
  class PaperSync < Sync
    validates :paper, :salesforce_api, presence: true

    attr_accessor :paper, :salesforce_api

    def initialize(paper:, salesforce_api: SalesforceServices::API)
      @paper = paper
      @salesforce_api = salesforce_api
    end

    def sync!
      if valid?
        @salesforce_api.find_or_create_manuscript(paper: @paper)
      else
        fail SyncInvalid, sync_invalid_message
      end
    end

    private

    def sync_invalid_message
      <<-MESSAGE.strip_heredoc
        The paper cannot be sent to Salesforce because it has missing
        or invalid information:

        #{errors.full_messages.join("\n")}

        The paper was: #{@paper.inspect}
      MESSAGE
    end
  end
end
