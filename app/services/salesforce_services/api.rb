module SalesforceServices
  class API
    include ObjectTranslations

    def self.client
      # ensure client has an authenticated session and defines (materializes) constants
      @@client ||= begin
        client = Databasedotcom::Client.new(
          host: TahiEnv.databasedotcom_host,
          client_id: TahiEnv.databasedotcom_client_id,
          client_secret: TahiEnv.databasedotcom_client_secret
        )

        client.authenticate username: TahiEnv.databasedotcom_username,
                            password: TahiEnv.databasedotcom_password
        Rails.logger.info("established Salesforce client connection")

        client.materialize("Manuscript__c")
        client.materialize("Case")
        client
      end
    end

    def self.create_manuscript(paper:)
      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      sf_paper = Manuscript__c.create(mt.paper_to_manuscript_hash)
      Rails.logger.info("Salesforce Manuscript created: #{sf_paper.Id}")

      paper.update_attribute(:salesforce_manuscript_id, sf_paper.Id)
      sf_paper
    end

    def self.update_manuscript(paper:)
      mt         = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      sf_paper   = Manuscript__c.find(paper.salesforce_manuscript_id)
      Rails.logger.info("Salesforce Manuscript updated: #{sf_paper.Id}")

      sf_paper.update_attributes mt.paper_to_manuscript_hash
      sf_paper
    rescue Databasedotcom::SalesForceError => ex
      if ex.message == "The requested resource does not exist"
        Rails.logger.warn(
          "Paper #{paper.inspect} not found on SFDC. Removing SFDC Id from paper."
        )
        paper.update_attribute(:salesforce_manuscript_id, nil)
      end
      raise ex
    end

    def self.find_or_create_manuscript(paper:)
      if paper.salesforce_manuscript_id
        update_manuscript(paper: paper)
      else
        create_manuscript(paper: paper)
      end
    end

    def self.ensure_pfa_case(paper:)
      return if Case.find_by_Subject(paper.manuscript_id)

      bt       = BillingTranslator.new(paper: paper)
      kase     = Case.create(bt.paper_to_billing_hash)
      Rails.logger.info("Salesforce Case created: #{kase.Id}")
      kase
    end
  end
end
