module Typesetter
  # Serializes a paper's billing log information
  # Expects a paper as its object to serialize.
  class BillingLogSerializer < Typesetter::TaskAnswerSerializer
    attributes :ned_id, :corresponding_author_ned_id, :corresponding_author_ned_email,
               :title, :journal, :doi, :firstname, :middlename, :lastname,
               :institute, :department, :address1, :address2, :address3,
               :city, :state, :zip, :country, :phone1, :phone2, :fax,
               :email, :pubdnumber, :dtitle, :fundRef,
               :collectionID, :collection, :direct_bill_response, :gpi_response,
               :final_dispo_accept, :category, :import_date
    attribute :id, key: :documentid
    attribute :first_submitted_at, key: :original_submission_start_date
    attribute :accepted_at, key: :date_first_entered_production

    def ned_id
      User.find_by(email: email).try(:ned_id)
    end

    def corresponding_author_ned_id
      object.creator.ned_id
    end

    def corresponding_author_ned_email
      object.creator.email
    end

    def title
      billing_answer_for('plos_billing--title')
    end

    def journal
      object.journal.name
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
      # pbio.000001
      object.manuscript_id
    end

    def dtitle
      object.title
    end

    # rubocop:disable Style/GuardClause
    def fundRef
      financial_disclosure_statement = FinancialDisclosureStatement.new(object)

      if financial_disclosure_statement.asked?
        financial_disclosure_statement.funding_statement
      end
    end
    # rubocop:enable Style/GuardClause

    def collectionID
      # To reference a Collection
    end

    def collection
      # Collection name
    end

    def direct_bill_response
      return unless billing_answer_for(
        'plos_billing--payment_method') == 'institutional'
      additional_data =
        billing_task.answer_for('plos_billing--ringgold_institution').try(:additional_data)
      additional_data['nav_customer_number'] if additional_data
    end

    def gpi_response
      return unless billing_answer_for('plos_billing--payment_method') == 'gpi'
      billing_answer_for('plos_billing--gpi_country')
    end

    def final_dispo_accept
      object.accepted_at
    end

    def category
      object.paper_type
    end

    def import_date
      # Intentionally left blank as this is handled by the billing program
    end

    private

    def billing_task
      task('PlosBilling::BillingTask')
    end

    def billing_answer_for(ident)
      answer = task('PlosBilling::BillingTask').answer_for(ident)
      answer.value if answer
    end

    def final_tech_check_task
      task('PlosBioTechCheck::FinalTechCheckTask')
    end
  end
end
