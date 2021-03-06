# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# rubocop:disable LineLength
module SalesforceServices
  module ObjectTranslations
    # This class extracts Salesforce manuscript data from a paper
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
        paper.co_authors.map do |a|
          "#{a.first_name} #{a.last_name}, #{a.email}, #{a.affiliation}"
        end.join('; ')
      end
    end

    # This class extracts Salesforce billing data from a paper
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
          'PFA_Funding_Statement__c'   => funding_statement
        }
      end

      private

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

      # rubocop:disable Style/GuardClause
      def funding_statement
        financial_disclosure_statement = FinancialDisclosureStatement.new(@paper)

        if financial_disclosure_statement.asked?
          financial_disclosure_statement.funding_statement
        end
      end
      # rubocop:enable Style/GuardClause
    end
  end
end
