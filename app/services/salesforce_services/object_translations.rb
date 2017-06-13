# rubocop:disable LineLength
module SalesforceServices
  module ObjectTranslations
    # This class extracts salesforce manuscript data from a paper
    class ManuscriptTranslator
      def initialize(user_id:, paper:)
        @user_id = user_id
        @paper = paper
      end

      def paper_to_manuscript_hash
        hash = {
          "RecordTypeId"               => "012U0000000E4ASIA0",
          "Editorial_Status_Date__c"   => editorial[:date],
          "Revision__c"                => @paper.major_version,
          "Title__c"                   => @paper.title,
          "DOI__c"                     => @paper.doi,
          "Name"                       => @paper.manuscript_id,
          "Abstract__c"                => @paper.abstract,
          "Current_Editorial_Status__c" => editorial[:status],
          "Co_Authors__c"               => co_authors_to_string(@paper)
        }

        if new_sfdc_record?
          hash["Initial_Date_Submitted__c"] = @paper.submitted_at
        end

        hash
      end

      private

      def editorial
        case @paper.publishing_state
        when 'submitted'
          { status: "Manuscript Submitted", date: @paper.submitted_at }
        when 'accepted'
          { status: "Completed Accept", date: @paper.accepted_at }
        when 'rejected'
          { status: "Completed Reject", date: @paper.updated_at }
        when 'withdrawn'
          { status: "Completed Withdrawn", date: @paper.updated_at }
        else
          { status: "Manuscript Submitted", date: @paper.submitted_at }
        end
      end

      def new_sfdc_record?
        !@paper.salesforce_manuscript_id
      end

      def co_authors_to_string(paper)
        co_authors_string = ""
        paper_co_authors(paper).each do |a|
          co_authors_string += "#{a.first_name} #{a.last_name}, #{a.email}, #{a.affiliation}; "
        end
        co_authors_string[0...-2]
      end

      def paper_co_authors(paper)
        creator = paper.assignments.find { |assignment| assignment.role.name == 'Creator' }.user
        co_authors = paper.authors.select do |author|
          author.first_name != creator.first_name && author.last_name != creator.last_name
        end
      end
    end

    # This class extracts salesforce billing data from a paper
    class BillingTranslator
      def initialize(paper:)
        @paper = paper
      end

      def paper_to_billing_hash # (pfa)
        {
          'RecordTypeId'               => "012U0000000DqUyIAK",
          'Manuscript__c'              => @paper.salesforce_manuscript_id,
          'SuppliedEmail'              => @paper.creator.email, # corresponding author == creator?
          'Exclude_from_EM__c'         => true,
          'Journal_Department__c'      => @paper.journal.name,
          'Subject'                    => @paper.manuscript_id,
          'Description'                => "#{@paper.creator.full_name} has applied for PFA with submission #{@paper.manuscript_id}",
          'Origin'                     => "PFA Request",
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
          'PFA_Supporting_Docs__c'     => answer_for("plos_billing--pfa_supporting_docs"),
          'PFA_Funding_Statement__c'   => financial_disclosure_task.try(:funding_statement)
        }
      end

      private

      delegate :financial_disclosure_task, to: :@paper, allow_nil: true

      def answer_for(ident)
        @paper.answer_for(ident).try(:value)
      end

      def value_or_nil(ident)
        value = @paper.answer_for(ident).try(:value)
        return nil if value.nil?
        yield value
      end

      def float_answer_for(ident)
        value_or_nil(ident, &:to_f)
      end

      def yes_no_answer_for(ident)
        value_or_nil(ident) { |value| value == true ? 'Yes' : 'No' }
      end
    end
  end
end
