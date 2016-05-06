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
               :final_dispo_accept, :category, :s3_url
    attribute :id, key: :documentid
    attribute :first_submitted_at, key: :original_submission_start_date
    attribute :accepted_at, key: :date_first_entered_production

    def some_guid
      1
    end

    def firstname
      #billing_answer_for('plos_billing--first_name')
    end

    def middlename
    end

    def lastname
      object.creator.last_name
    end

    def institute
    end

    def department
    end

    def address1
    end

    def address2
    end

    def address3
    end

    def city
    end

    def state
    end

    def zip
    end

    def country
    end

    def phone1
    end

    def phone2
    end

    def fax
    end

    def email
    end

    def pubdnumber
    end

    def dtitle
    end

    def fundRef
    end

    def collectionID
    end

    def collection
    end

    def direct_bill_response
    end

    def gpi_response
    end

    def final_dispo_accept
    end

    def category
    end

    def s3_url
    end

    private

    def billing_task
      task('PlosBilling::BillingTask')
    end

    def billing_answer_for(ident)
      answer = task('PlosBilling::BillingTask').answer_for(ident)
      answer.value if answer
    end
  end
end
