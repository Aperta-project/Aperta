# rubocop:disable LineLength
require 'rails_helper'

describe SalesforceServices::ObjectTranslations do
  before do
    allow(Paper).to receive(:find).with(paper.id).and_return(paper)
    allow(paper).to receive(:creator) { user }
    paper.submit! user
  end

  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  describe "ManuscriptTranslator#paper_to_manuscript_hash" do
    let(:mt) do
      SalesforceServices::ObjectTranslations::ManuscriptTranslator.new(user_id: user.id, paper: paper)
    end

    let(:submit_time) { Time.now.utc + 20 }
    let(:accepted_time) { Time.now.utc + 30 }
    let(:rejected_time) { Time.now.utc + 40 }

    it "returns a hash" do
      expect(mt.paper_to_manuscript_hash.class).to eq Hash
    end

    context 'new manuscript' do
      subject { mt.paper_to_manuscript_hash }
      before do
        paper.salesforce_manuscript_id = nil
      end

      it 'sends Initial_Date_Submitted__c' do
        is_expected.to include("Initial_Date_Submitted__c")
      end
    end

    context 'existing manuscript' do
      subject { mt.paper_to_manuscript_hash }
      before do
        paper.salesforce_manuscript_id = "foreign_id"
        paper.save
      end
      it 'does not send Initial_Date_Submitted__c' do
        is_expected.not_to include("Initial_Date_Submitted__c")
      end
    end

    it "returns a hash with the required fields" do
      paper.update_attributes(submitted_at: submit_time)

      hash = {
        "RecordTypeId"               => "012U0000000E4ASIA0",
        "Editorial_Status_Date__c"   => submit_time,
        "Revision__c"                => 0,
        "Title__c"                   => paper.title,
        "DOI__c"                     => paper.doi,
        "Name"                       => paper.manuscript_id,
        "Initial_Date_Submitted__c"  => submit_time,
        "Abstract__c"                => paper.abstract,
        "Current_Editorial_Status__c" => "Manuscript Submitted"
      }

      expect(mt.paper_to_manuscript_hash).to eq(hash)
    end

    context "publishing states" do
      let(:states_config) do
        [
          { state: "submitted", time: submit_time, status: "Manuscript Submitted" },
          { state: "unknown_state", time: submit_time, status: "Manuscript Submitted" },
          { state: "accepted", time: accepted_time, status: "Completed Accept" },
          { state: "rejected", time: rejected_time, status: "Completed Reject" }
        ]
      end
      before do
        paper.update_attributes(submitted_at: submit_time, accepted_at: accepted_time)
      end

      it "uses the correct Editorial_Status_Date__c" do
        Timecop.freeze(rejected_time) do
          states_config.each do |config|
            paper.update_attributes(publishing_state: config[:state])
            expect(mt.paper_to_manuscript_hash["Editorial_Status_Date__c"])
              .to eq(config[:time])
          end

        end
      end
      it "uses the correct Current_Editorial_Status__c" do
        states_config.each do |config|
          paper.update_attributes(publishing_state: config[:state])
          expect(mt.paper_to_manuscript_hash["Current_Editorial_Status__c"])
            .to eq(config[:status])
        end
      end
    end
  end

  describe "BillingTranslator#paper_to_billing_hash" do
    let!(:funder) do
      FactoryGirl.create(:funder,
                         name: "funder001",
                         grant_number: '000-2222-111')
    end

    let(:journal) do
      FactoryGirl.create(
        :journal,
        :with_doi,
        name: 'journal name'
      )
    end

    let(:user) do
      FactoryGirl.create(:user,
                         first_name: 'lou',
                         last_name: 'prima',
                         email: 'pfa@pfa.com'
                        )
    end

    let(:paper) do
      FactoryGirl.create(:paper_with_task,
                         journal: journal,
                         task_params: {
                           title: "Billing",
                           type: "PlosBilling::BillingTask",
                           old_role: "author" }
                        )
    end

    it "return a hash" do
      paper = make_paper
      FactoryGirl.create(:financial_disclosure_task,
                         funders: [funder],
                         paper: paper)

      bt    = SalesforceServices::ObjectTranslations::BillingTranslator.new(paper: paper)
      data  = bt.paper_to_billing_hash
      # rubocop:disable Style/SingleSpaceBeforeFirstArg
      expect(data.class).to                          eq Hash
      expect(data['SuppliedEmail']).to               eq('pfa@pfa.com' )
      expect(data['Manuscript__c']).to               eq(paper.salesforce_manuscript_id)
      expect(data['Exclude_from_EM__c']).to          eq(true)
      expect(data['Journal_Department__c']).to       eq(paper.journal.name)
      expect(data['Subject']).to                     eq(paper.manuscript_id) # will prob change when doi is in RC?
      expect(data['Origin']).to                      eq('PFA Request')
      expect(data['Description']).to                 match('lou prima')
      expect(data['Description']).to                 match('has applied')
      expect(data['Description']).to                 match(paper.manuscript_id) # will prob change when doi is in RC?
      expect(data['PFA_Question_1__c']).to           eq ('Yes')
      expect(data['PFA_Question_1a__c']).to          eq ('foo')
      expect(data['PFA_Question_1b__c']).to          eq (100.00)
      expect(data['PFA_Question_2__c']).to           eq ('Yes')
      expect(data['PFA_Question_2a__c']).to          eq ('foo')
      expect(data['PFA_Question_2b__c']).to          eq (100.00)
      expect(data['PFA_Question_3__c']).to           eq ('Yes')
      expect(data['PFA_Question_3a__c']).to          eq (100.00)
      expect(data['PFA_Question_4__c']).to           eq ('Yes')
      expect(data['PFA_Question_4a__c']).to          eq (100.00)
      expect(data['PFA_Able_to_Pay_R__c']).to        eq (100.00)
      expect(data['PFA_Additional_Comments__c']).to  eq ('my comments')
      expect(data['PFA_Supporting_Docs__c']).to      eq (true) #indirectly tests private method boolean_from_yes_no
      expect(data['PFA_Funding_Statement__c']).to    eq ("This work was supported by funder001 (grant number 000-2222-111).")
      # rubocop:enable Style/SingleSpaceBeforeFirstArg
    end
  end

  def make_paper
    make_questions paper
    paper
  end

  def make_questions(paper)
    add_boolean_question_with_answer(paper, 'plos_billing--pfa_question_1',          'Yes')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_1a',         'foo')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_1b',         '100')
    add_boolean_question_with_answer(paper, 'plos_billing--pfa_question_2',          'Yes')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_2a',         'foo')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_2b',         '100')
    add_boolean_question_with_answer(paper, 'plos_billing--pfa_question_3',          'Yes')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_3a',         '100')
    add_boolean_question_with_answer(paper, 'plos_billing--pfa_question_4',          'Yes')
    add_text_question_with_answer(paper,    'plos_billing--pfa_question_4a',         '100')
    add_text_question_with_answer(paper,    'plos_billing--pfa_amount_to_pay',       '100')
    add_text_question_with_answer(paper,    'plos_billing--pfa_additional_comments', 'my comments')
    add_boolean_question_with_answer(paper, 'plos_billing--pfa_supporting_docs',     'Yes')
  end

  def add_text_question_with_answer(paper, ident, answer)
    nested_question = NestedQuestion.find_by(ident: ident) ||
      FactoryGirl.create(:nested_question, ident: ident, value_type: "text")
    nested_question_answer = FactoryGirl.create(
      :nested_question_answer,
      nested_question: nested_question,
      owner: paper.billing_card,
      value: answer,
      value_type: "text"
    )
  end

  def add_boolean_question_with_answer(paper, ident, answer)
    nested_question = NestedQuestion.find_by(ident: ident) ||
      FactoryGirl.create(:nested_question, ident: ident, value_type: "boolean")
    nested_question_answer = FactoryGirl.create(
      :nested_question_answer,
      nested_question: nested_question,
      owner: paper.billing_card,
      value: answer,
      value_type: "boolean"
    )
  end

end
