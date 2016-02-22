require 'rails_helper'

describe TablesController do
  let(:user) { FactoryGirl.create :user }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal)
  end

  before { sign_in user }

  authorize_policy(TablesPolicy, true)

  describe "#create" do
    let(:table_attributes) { FactoryGirl.attributes_for(:table) }

    pending "creates a new table record" do
      expect {
        post :create, paper_id: paper.id, table: table_attributes, format: :json
      }.to change{ paper.tables.reload.count }.by(1)
    end

    it "returns a 404 if paper_id is not sent" do
      post :create, table: table_attributes, format: :json
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    let(:table) { FactoryGirl.create(:table, paper: paper) }
    let(:body) { "<table><tr><td>new</td></tr></table>" }

    it "updates an existing table record" do
      put :update, id: table.id, paper_id: paper.id, table: { body: body }, format: :json
      expect(table.reload.body).to eq(body)
    end
  end

  describe "#destroy" do
    let!(:table) { FactoryGirl.create(:table, paper: paper) }

    it "destroys the table record" do
      expect {
        delete :destroy, id: table.id, paper_id: paper.id, format: :json
      }.to change{ paper.tables.reload.count }.by(-1)
    end
  end
end
