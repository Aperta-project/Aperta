module SalesforceServices
  class API
    include ObjectTranslations

    def self.client
      @@client ||= begin
        client = Databasedotcom::Client.new(
          host: Rails.configuration.salesforce_host,
          client_id: Rails.configuration.salesforce_client_id,
          client_secret: Rails.configuration.salesforce_client_secret
        )

        client.authenticate username: Rails.configuration.salesforce_username,
                            password: Rails.configuration.salesforce_password
        Rails.logger.info("established Salesforce client connection")

        client.materialize("Manuscript__c")
        client.materialize("Case")
        client
      end
    end

    def self.create_manuscript(paper:)
      return unless salesforce_active

      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      sf_paper = Manuscript__c.create(mt.paper_to_manuscript_hash)
      Rails.logger.info("Salesforce Manuscript created: #{sf_paper.Id}")

      paper.update_attribute(:salesforce_manuscript_id, sf_paper.Id)
      sf_paper
    end

    def self.update_manuscript(paper:)
      return unless salesforce_active

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
      return unless salesforce_active

      if paper.salesforce_manuscript_id
        update_manuscript(paper: paper)
      else
        create_manuscript(paper: paper)
      end
    end

    def self.ensure_pfa_case(paper:)
      return unless salesforce_active
      return if Case.find_by_Subject(paper.manuscript_id)

      bt       = BillingTranslator.new(paper: paper)
      kase     = Case.create(bt.paper_to_billing_hash)
      Rails.logger.info("Salesforce Case created: #{kase.Id}")
      kase
    end

    def self.salesforce_active
      active = TahiEnv.salesforce_enabled?
      if active
        # ensure client has a session with SObjects materialized
        client
      else
        Rails.logger.warn(<<-INFO.strip_heredoc.chomp)
          Salesforce integration disabled due to ENV['SALESFORCE_ENABLED']
        INFO
      end
      active
    end
  end
end
