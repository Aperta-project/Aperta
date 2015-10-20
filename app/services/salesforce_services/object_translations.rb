module SalesforceServices
  module ObjectTranslations

    class ManuscriptTranslator
      def initialize(user_id:, paper:)
        @user_id = user_id
        @paper = paper
      end

      def paper_to_manuscript_hash
        {
          "RecordTypeId" => "012U0000000E4ASIA0",
          "OwnerId" => @user_id,
          "Editorial_Process_Close__c" => false,
          "Display_Technical_Notes__c" => false,
          "CreatedByDeltaMigration__c" => false,
          "Editorial_Status_Date__c" => Time.now,
          "Revision__c" => @paper.decisions.latest.revision_number,
          "Title__c" => @paper.title,
          "Initial_Date_Submitted__c" => @paper.submitted_at,
          "Manuscript_Number__c" => @paper.doi,
          "OriginalSubmissionDate__c" => @paper.submitted_at,
          "DOI__c" => @paper.doi
        }
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
          'Subject'                    => manuscript_id,
          'Description'                => "#{@paper.creator.full_name} has applied for PFA with submission #{manuscript_id}",
          'Origin'                     => "PFA Request",

          #'PFA_Funding_Statement__c'   => billing_question "", # Unknown field? from financial disclosure card

          'PFA_Question_1__c'          => answer_for("pfa_question_1"),
          'PFA_Question_1a__c'         => answer_for("pfa_question_1a"),
          'PFA_Question_1b__c'         => float_answer_for("pfa_question_1b"),
          'PFA_Question_2__c'          => answer_for("pfa_question_2"),
          'PFA_Question_2a__c'         => answer_for("pfa_question_2a"),
          'PFA_Question_2b__c'         => float_answer_for("pfa_question_2b"),
          'PFA_Question_3__c'          => answer_for("pfa_question_3"),
          'PFA_Question_3a__c'         => float_answer_for("pfa_question_3a"),
          'PFA_Question_4__c'          => answer_for("pfa_question_4"),
          'PFA_Question_4a__c'         => float_answer_for("pfa_question_4a"),
          'PFA_Able_to_Pay_R__c'       => float_answer_for("pfa_amount_to_pay"),
          'PFA_Additional_Comments__c' => answer_for("pfa_additional_comments"),
          'PFA_Supporting_Docs__c'     => boolean_from_yes_no("pfa_supporting_docs"),
        }
      end

      private

      def answer_for(ident)
        q = @paper.billing_card.questions.find_by_ident("plos_billing.#{ident}")
        q.present? ? q.answer : nil
      end

      def float_answer_for(ident) # for data that must be castable to float
        answer_for(ident).to_f
      end

      def boolean_from_yes_no(ident) # when must bool in SF, but stored as y/n in Aperta
        a = answer_for(ident)
        a.is_a?(String) ? text_to_boolean_map[a.downcase] : false
      end

      def text_to_boolean_map
        {
          'yes' => true,
          'no'  => false,
        }
      end

      def manuscript_id # TODO ask product what to do in case of no DOI
        @paper.doi || "doi_missing_for_id_#{@paper.id}"
      end
    end
  end
end
