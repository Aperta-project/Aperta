module SalesforceServices
  module ObjectTranslations

    class ManuscriptTranslator
      def initialize(user_id:, paper:)
        @user_id = user_id
        @paper = paper
      end

      def editorial
        status = @paper.publishing_state
        sfdc_status = {
          submitted: status_hash("Manuscript Submitted", :submitted_at),
          accepted: status_hash("Completed Accept", :accepted_at),
          rejected: status_hash("Completed Reject", :updated_at)
        }[status.to_sym]

        sfdc_status || status_hash("Manuscript Submitted", :submitted_at)
      end

      def paper_to_manuscript_hash
        hash = {
          "RecordTypeId"               => "012U0000000E4ASIA0",
          "Editorial_Status_Date__c"   => editorial[:date],
          "Revision__c"                => @paper.decisions.latest.revision_number,
          "Title__c"                   => @paper.title,
          "DOI__c"                     => @paper.doi,
          "Name"                       => @paper.manuscript_id,
          "Abstract__c"                => @paper.abstract,
          "Current_Editorial_Status__c" => editorial[:status]
        }

        if new_sfdc_record?
          hash["OriginalSubmissionDate__c"] = @paper.submitted_at
        end

        hash
      end

      private

      def new_sfdc_record?
        !@paper.salesforce_manuscript_id
      end

      def status_hash(sfdc_value, local_datetime_field)
        { status: sfdc_value, date: @paper.send(local_datetime_field) }
      end
    end

    class BillingTranslator
      def initialize(paper:)
        @paper = paper
      end

      def paper_to_billing_hash # (pfa)
        {
          'RecordTypeId'               => "012U0000000DqUyIAK",
          'SuppliedEmail'              => @paper.creator.email, # corresponding author == creator?
          'Exclude_from_EM__c'         => true,
          'Journal_Department__c'      => @paper.journal.name,
          'Subject'                    => @paper.manuscript_id,
          'Description'                => "#{@paper.creator.full_name} has applied for PFA with submission #{@paper.manuscript_id}",
          'Origin'                     => "PFA Request",

          #'PFA_Funding_Statement__c'   => billing_question "", # Unknown field? from financial disclosure card

          'PFA_Question_1__c'          => yes_no_answer_for("plos_billing--pfa_question_1"),
          'PFA_Question_1a__c'         => answer_for("plos_billing--pfa_question_1a"),
          'PFA_Question_1b__c'         => float_answer_for("plos_billing--pfa_question_1b"),
          'PFA_Question_2__c'          => yes_no_answer_for("plos_billing--pfa_question_2"),
          'PFA_Question_2a__c'         => answer_for("plos_billing--pfa_question_2a"),
          'PFA_Question_2b__c'         => float_answer_for("plos_billing--pfa_question_2b"),
          'PFA_Question_3__c'          => yes_no_answer_for("plos_billing--pfa_question_3"),
          'PFA_Question_3a__c'         => float_answer_for("plos_billing--pfa_question_3a"),
          'PFA_Question_4__c'          => yes_no_answer_for("plos_billing--pfa_question_4"),
          'PFA_Question_4a__c'         => float_answer_for("plos_billing--pfa_question_4a"),
          'PFA_Able_to_Pay_R__c'       => float_answer_for("plos_billing--pfa_amount_to_pay"),
          'PFA_Additional_Comments__c' => answer_for("plos_billing--pfa_additional_comments"),
          'PFA_Supporting_Docs__c'     => answer_for("plos_billing--pfa_supporting_docs")
        }
      end

      private

      def answer_for(ident)
        answer = billing_card.answer_for(ident)
        answer.value if answer
      end

      def float_answer_for(ident)
        answer = billing_card.answer_for(ident)
        answer.float_value if answer
      end

      def yes_no_answer_for(ident)
        answer = billing_card.answer_for(ident)
        answer.yes_no_value if answer
      end

      def billing_card
        @paper.billing_card
      end

      def manuscript_id # TODO ask product what to do in case of no DOI
        @paper.doi || "doi_missing_for_id_#{@paper.id}"
      end
    end
  end
end
