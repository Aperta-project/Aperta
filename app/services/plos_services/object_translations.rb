module PlosServices
  module ObjectTranslations

    class BillingTranslator
      def initialize(paper:)
        @paper = paper
      end

      def paper_to_billing_log_hash
        {
          guid: "PONE-2", # @paper.creator.em_guid, when em_guid is merged
          document_id: @paper.doi,
          title: @paper.title,
          first_name: @paper.creator.first_name,
          middlename: "middleName", # TODO: update when Aperta supports this
          lastname: @paper.creator.last_name,
          institute: "placeholderInstitute",
          department: "placeholderDepartment",
          address1: answer_for("address1"),
          address2: answer_for("address2"),
          address3: "",
          city: answer_for("city"),
          state: answer_for("state"),
          zip: answer_for("postal_code"),
          country: "",
          phone1: answer_for("phone"),
          phone2: "",
          fax: "",
          email: @paper.creator.email,
          journal: @paper.journal.name,
          pubdnumber: "placeholderPubDNumber",
          doi: @paper.doi,
          dtitle: @paper.title,
          issn: "",
          price: "",
          waiver_text: "", # highlighted in Linda's spreadsheet. not sure why
          discount_institution: "", # highlighted
          collection: "", # highlighted
          direct_bill: "", # highlighted
          import_date: "",
          line_no: "",
          original_submission_start_date: "",
          actual_online_pub_date: "",
          batch_no: "",
          exception: "",
          direct_bill_expense: "", # highlighted
          date_first_entered_production: "", # highlighted
          pub_charge_response: "", # highlighted
          pub_waiver_response: "", # highlighted
          institutional_response: "", # highlighted
          gpi_response: "", # highlighted
          gpi_tier: "",
          base_price: "",
          discount_price: "",
          discount_percent: "",
          waiver_amount: "",
          collections_response: "", # highlighted
          eligible: "",
          rescind: "",
          standard_collection_id: "",
          terms1: "",
          terms2: "",
          terms3: "",
          terms4: "",
          terms5: "",
          final_dispo_accept: "placeholderFinalDispoAccept",
          terms6: "",
          category: "placeholderCategory",
          split: ""
        }
      end

      def send_csv_to_s3
        filepath = to_csv
        to_s3(filepath)
      end

      def to_csv
        require 'csv'

        hash = paper_to_billing_log_hash

        file_path = "billing-log-#{Time.now.to_i}.csv"

        CSV.open("tmp/#{file_path}", "w") do |csv|
          csv << hash.keys
          csv << hash.values
        end

        file_path
      end

      def to_s3(filepath)
        connection = Fog::Storage.new({
          provider: 'AWS',
          aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          region: ENV['AWS_REGION']
        })

        directory = connection.directories.new(
          key: Rails.application.config.s3_bucket,
          public: false
        )

        s3_file = directory.files.create(
          key: "billing/#{filepath}",
          body: File.open("tmp/#{filepath}"),
          public: true
        )

        s3_file.save
      end

      private

      # TODO:
      # These methods are duplicated in SalesforceServices::ObjectTranslations as well

      def answer_for(ident)
        q = @paper.billing_card.questions.find_by_ident("plos_billing.#{ident}")
        q.present? ? q.answer : nil
      end

      def boolean_from_text_answer_for(ident)
        a = answer_for(ident)
        a.is_a?(String) ? text_to_boolean_map[a.downcase] : false
      end

      def text_to_boolean_map
        {
          'yes' => true,
          'no'  => false,
        }
      end
    end
  end
end
