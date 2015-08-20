require 'singleton'

module SalesforceServices
  class API
    include Singleton
    include ObjectTranslations

    attr_accessor :client

    def initialize
      @client = Databasedotcom::Client.new(
        host: Rails.configuration.salesforce_host,
        client_id: Rails.configuration.salesforce_client_id,
        client_secret: Rails.configuration.salesforce_client_secret
      )
      @client.authenticate username: Rails.configuration.salesforce_username,
                           password: Rails.configuration.salesforce_password
    end

    def create_manuscript(paper:)
      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      manuscript = client.materialize("Manuscript__c")
      manuscript.create(mt.paper_to_manuscript_hash)
    end
  end
end
