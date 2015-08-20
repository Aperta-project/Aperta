module SalesforceServices
  class API
    include ObjectTranslations

    def self.get_client
      client = Databasedotcom::Client.new(
        host: Rails.configuration.salesforce_host,
        client_id: Rails.configuration.salesforce_client_id,
        client_secret: Rails.configuration.salesforce_client_secret
      )

      client.authenticate username: Rails.configuration.salesforce_username,
                          password: Rails.configuration.salesforce_password

      client
    end
    def self.client
      @@client ||= self.get_client
    end

    def self.create_manuscript(paper_id:)
      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: Paper.find(paper_id))
      manuscript = self.client.materialize("Manuscript__c")
      manuscript.create(mt.paper_to_manuscript_hash)
    end
  end
end
