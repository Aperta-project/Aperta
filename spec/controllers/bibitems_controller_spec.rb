require 'rails_helper'

describe BibitemsController do
  let(:user)  { create :user }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end

  before { sign_in user }

  authorize_policy(BibitemsPolicy, true)

  describe "#create" do
    let(:bibitem_attributes) { FactoryGirl.attributes_for(:bibitem) }

    it "returns a 404 if paper_id is not sent" do
      post :create, bibitem: bibitem_attributes, format: :json
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    let(:bibitem) { FactoryGirl.create(:bibitem, paper: paper) }
    let(:content) { '{ "doi": "test" }' }

    it "updates an existing bibitem record" do
      put :update, id: bibitem.id, paper_id: paper.id, bibitem: { content: content }, format: :json
      expect(bibitem.reload.content).to eq(content)
    end
  end

  describe "#destroy" do
    let!(:bibitem) { FactoryGirl.create(:bibitem, paper: paper) }

    it "destroys the bibitem record" do
      expect {
        delete :destroy, id: bibitem.id, paper_id: paper.id, format: :json
      }.to change{ paper.bibitems.reload.count }.by(-1)
    end
  end
end
