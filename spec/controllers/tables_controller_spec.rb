require 'rails_helper'

describe TablesController do
  let(:user)  { create :user }
  let(:paper) { FactoryGirl.create(:paper, creator: user) }

  before { sign_in user }

  describe "#create" do
    let(:table_attributes) { FactoryGirl.attributes_for(:table) }

    it "creates a new table record" do
      expect {
        post :create, paper_id: paper.id, table: table_attributes, format: :json
      }.to change{ paper.tables.reload.count }.by(1)
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
