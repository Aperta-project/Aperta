module SalesforceServices
  class API
    include ObjectTranslations

    def self.get_client
      unless has_valid_creds?
        Rails.logger.warn "SalesForce credentials are not set. Information will NOT be synced to SalesForce"
        return
      end

      client = Databasedotcom::Client.new(
        host: Rails.configuration.salesforce_host,
        client_id: Rails.configuration.salesforce_client_id,
        client_secret: Rails.configuration.salesforce_client_secret
      )

      client.authenticate username: Rails.configuration.salesforce_username,
                          password: Rails.configuration.salesforce_password
      Rails.logger.info("established Salesforce client connection")

      client
    end

    def self.client
      @@client ||= self.get_client # TODO: reauthenticate when 'Session Expired'?
    end

    def self.create_manuscript(paper_id:)
      paper = Paper.find(paper_id)

      mt = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      manuscript = client.materialize("Manuscript__c")
      sf_paper = manuscript.create(mt.paper_to_manuscript_hash)
      Rails.logger.info("Salesforce Manuscript created: #{sf_paper.Id}")

      paper.update_attribute(:salesforce_manuscript_id, sf_paper.Id)
      sf_paper
    end

    def self.update_manuscript(paper_id:)
      paper = Paper.find(paper_id)

      mt         = ManuscriptTranslator.new(user_id: client.user_id, paper: paper)
      manuscript = client.materialize("Manuscript__c")
      sf_paper   = manuscript.find(paper.salesforce_manuscript_id)
      Rails.logger.info("Salesforce Manuscript updated: #{sf_paper.Id}")

      sf_paper.update_attributes mt.paper_to_manuscript_hash
      sf_paper
    end

    def self.find_or_create_manuscript(paper_id:)
      unless client
        Rails.logger.warn "No valid SalesForce client. Information will NOT be synced to SalesForce"
        return
      end

      p = Paper.find(paper_id)
      if p.salesforce_manuscript_id
        update_manuscript(paper_id: paper_id)
      else
        create_manuscript(paper_id: paper_id)
      end
    end

    def self.create_billing_and_pfa_case(paper_id:) # assumes paper.billing_card
      paper    = Paper.find(paper_id)
      kase_mgr = self.client.materialize("Case")
      bt       = BillingTranslator.new(paper: paper)
      kase     = kase_mgr.create(bt.paper_to_billing_hash)
      Rails.logger.info("Salesforce Case created: #{kase.Id}")
      kase
    end

    def self.has_valid_creds?
      [ :salesforce_client_id, :salesforce_host, :salesforce_client_secret, :salesforce_username, :salesforce_password ].each do |key|
        return false if !Rails.configuration.respond_to?(key) || Rails.configuration.send(key) == :not_set
      end
      true
    end

  end
end
