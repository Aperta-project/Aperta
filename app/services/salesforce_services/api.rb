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

    def self.create_manuscript(paper_id:)
      return unless salesforce_active

      paper = Paper.find(paper_id)

      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      sf_paper = Manuscript__c.create(mt.paper_to_manuscript_hash)
      Rails.logger.info("Salesforce Manuscript created: #{sf_paper.Id}")

      paper.update_attribute(:salesforce_manuscript_id, sf_paper.Id)
      sf_paper
    end

    def self.update_manuscript(paper_id:)
      return unless salesforce_active

      paper = Paper.find(paper_id)
      mt         = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      sf_paper   = Manuscript__c.find(paper.salesforce_manuscript_id)
      Rails.logger.info("Salesforce Manuscript updated: #{sf_paper.Id}")

      sf_paper.update_attributes mt.paper_to_manuscript_hash
      sf_paper
    end

    def self.find_or_create_manuscript(paper_id:)
      return unless salesforce_active

      p = Paper.find(paper_id)
      if p.salesforce_manuscript_id
        update_manuscript(paper_id: paper_id)
      else
        create_manuscript(paper_id: paper_id)
      end
    end

    def self.create_billing_and_pfa_case(paper_id:)
      return unless salesforce_active

      paper    = Paper.find(paper_id)
      bt       = BillingTranslator.new(paper: paper)
      kase     = Case.create(bt.paper_to_billing_hash)
      Rails.logger.info("Salesforce Case created: #{kase.Id}")
      kase
    end

    def self.salesforce_active
      active = ENV['DATEBASEDOTCOM_DISABLED'] == 'true' ? false : true
      Rails.logger.warn(<<-INFO.strip_heredoc.chomp)
        Salesforce integration disabled due to ENV['DATEBASEDOTCOM_DISABLED]'
      INFO
      client if active
      active
    end
  end
end
