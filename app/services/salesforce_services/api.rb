module SalesforceServices
  class API
    include ObjectTranslations

    def self.build_client
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
      @client ||= build_client
    end

    def self.instance
      @instance ||= new(client)
    end

    def self.sync_manuscript(paper_id:)
      p = Paper.find(paper_id)
      if p.salesforce_manuscript_id
        instance.update_manuscript(paper_id: paper_id)
      else
        instance.create_manuscript(paper_id: paper_id)
      end
    end

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def create_manuscript(paper_id:)
      paper = Paper.find(paper_id)

      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      manuscript = self.client.materialize("Manuscript__c")
      sf_paper = manuscript.create(mt.paper_to_manuscript_hash)

      paper.update_attribute(:salesforce_manuscript_id, sf_paper.Id)
      sf_paper
    end

    def update_manuscript(paper_id:)
      paper = Paper.find(paper_id)

      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      manuscript = self.client.materialize("Manuscript__c")
      sf_paper = manuscript.find(paper.salesforce_manuscript_id)
      sf_paper.update_attributes mt.paper_to_manuscript_hash
      sf_paper
    end

  end
end
