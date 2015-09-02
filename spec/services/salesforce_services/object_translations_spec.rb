require 'rails_helper'

describe SalesforceServices::ObjectTranslations do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:mt) do
    SalesforceServices::ObjectTranslations::ManuscriptTranslator.new(user_id: user.id, paper: paper)
  end

  describe "ManuscriptTranslator#paper_to_manuscript_hash" do
    it "return a hash" do
      expect(mt.paper_to_manuscript_hash.class).to eq Hash
    end
  end

  describe "BillingTranslator#paper_to_billing_hash" do
    it "return a hash" do
      paper = FactoryGirl.create :paper_with_task, { 
        creator: FactoryGirl.create(:user, { first_name: 'lou', last_name: 'prima', email: 'pfa@pfa.com' }),
        journal: FactoryGirl.create(:journal, { name: 'journal name' }),
        short_title: "my title", 
        task_params: { title: "Billing", type: "PlosBilling::BillingTask", role: "author" }
      }
      ap paper.creator
      bt    = SalesforceServices::ObjectTranslations::BillingTranslator.new(paper: paper)
      data  = bt.paper_to_billing_hash
      ap data
      expect(data.class).to eq Hash

      expect(data['SuppliedEmail']).to               eq('pfa@pfa.com' )
      expect(data['Exclude_from_EM__c']).to          eq(true)
      expect(data['Journal_Department__c']).to       eq(paper.journal.name)
      expect(data['Subject']).to                     eq("prefix-#{paper.id}") # will chane when doi story is done
      expect(data['Origin']).to                      eq('PFA Request')
      expect(data['Description']).to                 match('lou prima') 
      expect(data['Description']).to                 match('has applied')
      expect(data['Description']).to                 match("prefix-#{paper.id}") 
      #expect(data['PFA_Question_1__c']).to          eq () # => answer_for("pfa_question_1"),
      #expect(data['PFA_Question_1a__c']).to         eq () # => answer_for("pfa_question_1a"),
      #expect(data['PFA_Question_1b__c']).to         eq () # => answer_for("pfa_question_1b"),
      #expect(data['PFA_Question_2__c']).to          eq () # => answer_for("pfa_question_2"),
      #expect(data['PFA_Question_2a__c']).to         eq () # => answer_for("pfa_question_2a"),
      #expect(data['PFA_Question_2b__c']).to         eq () # => answer_for("pfa_question_2b"),
      #expect(data['PFA_Question_3__c']).to          eq () # => answer_for("pfa_question_3"),
      #expect(data['PFA_Question_3a__c']).to         eq () # => answer_for("pfa_question_3a"),
      #expect(data['PFA_Question_4__c']).to          eq () # => answer_for("pfa_question_4"),
      #expect(data['PFA_Question_4a__c']).to         eq () # => answer_for("pfa_question_4a"),
      #expect(data['PFA_Able_to_Pay_R__c']).to       eq () # => answer_for("pfa_amount_to_pay"),
      #expect(data['PFA_Additional_Comments__c']).to eq () # => answer_for("pfa_additional_comments"),
      #expect(data['PFA_Supporting_Docs__c']).to     eq () # => answer_for("payment_method"), # can't be nil, unlike others
    end
  end

end
