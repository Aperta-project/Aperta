require 'rails_helper'

describe SalesforceServices::ObjectTranslations do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:mt) do
    SalesforceServices::ObjectTranslations::ManuscriptTranslator.new(user_id: user.id, paper: paper)
  end
  let(:bt) do
    SalesforceServices::ObjectTranslations::BillingTranslator.new(paper: paper)
  end

  describe "ManuscriptTranslator#paper_to_manuscript_hash" do
    it "return a hash" do
      expect(mt.paper_to_manuscript_hash.class).to eq Hash
    end
  end

  describe "BillingTranslator#paper_to_billing_hash" do
    it "return a hash" do
      expect(bt.paper_to_billing_hash.class).to eq Hash
    end
  end

end
