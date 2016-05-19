module Typesetter
  # Serializes a paper's billing log information
  # Expects a paper as its object to serialize.
  class BillingLogSerializer < Typesetter::TaskAnswerSerializer
    attribute :some_guid, key: :guid
    attributes :title, :journal_id, :doi,
               :firstname, :middlename, :lastname,
               :institute, :department, :address1, :address2, :address3,
               :city, :state, :zip, :country, :phone1, :phone2, :fax,
               :email, :pubdnumber, :dtitle, :fundRef,
               :collectionID, :collection, :direct_bill_response, :gpi_response,
               :final_dispo_accept, :category, :import_date
    attribute :id, key: :documentid
    attribute :first_submitted_at, key: :original_submission_start_date
    attribute :accepted_at, key: :date_first_entered_production

    def some_guid
      PlosEditorialManager.find_or_create_guid_by_email(email: email)
    end

    def title
      billing_answer_for('plos_billing--title')
    end

    def firstname
      billing_answer_for('plos_billing--first_name')
    end

    def middlename
      # No middle name field on billing task
    end

    def lastname
      billing_answer_for('plos_billing--last_name')
    end

    def institute
      billing_answer_for('plos_billing--affiliation1')
    end

    def department
      billing_answer_for('plos_billing--department')
    end

    def address1
      billing_answer_for('plos_billing--address1')
    end

    def address2
      billing_answer_for('plos_billing--address2')
    end

    def address3
      # No address3 on billing task
    end

    def city
      billing_answer_for('plos_billing--city')
    end

    def state
      billing_answer_for('plos_billing--state')
    end

    def zip
      billing_answer_for('plos_billing--postal_code')
    end

    def country
      billing_answer_for('plos_billing--country')
    end

    def phone1
      billing_answer_for('plos_billing--phone_number')
    end

    def phone2
      # No phone2 on billing task
    end

    def fax
      # Who uses fax nowadays
    end

    def email
      billing_answer_for('plos_billing--email')
    end

    def pubdnumber
      # Same as manuscript id for now
      object.id
    end

    def dtitle
      object.title
    end

    def fundRef
      financial_disclosure_task.funding_statement
    end

    def collectionID
      # To reference a Collection
    end

    def collection
      # Collection name
    end

    def direct_bill_response
      return unless billing_answer_for(
        'plos_billing--payment_method') == 'institutional'
      billing_answer_for('plos_billing--ringgold_institution')
    end

    def gpi_response
      return unless billing_answer_for('plos_billing--payment_method') == 'gpi'
      billing_answer_for('plos_billing--gpi_country')
    end

    def final_dispo_accept
      final_tech_check_task.completed_at
    end

    def category
      object.paper_type
    end

    def import_date
      Time.current
    end

    private

    def billing_task
      task('PlosBilling::BillingTask')
    end

    def billing_answer_for(ident)
      answer = task('PlosBilling::BillingTask').answer_for(ident)
      answer.value if answer
    end

    def financial_disclosure_task
      task('TahiStandardTasks::FinancialDisclosureTask')
    end

    def final_tech_check_task
      task('PlosBioTechCheck::FinalTechCheckTask')
    end
  end
end
