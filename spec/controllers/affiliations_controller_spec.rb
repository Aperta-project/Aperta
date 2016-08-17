require 'rails_helper'

describe AffiliationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }
  before do
    sign_in user
    allow_any_instance_of(AffiliationsController).to receive(:requires_user_can).with(:manage_users, Journal) {true}
  end

  it "returns a list of the institution names" do
    get :index, query: "Harvard"
    institution_names = res_body['institutions'].map { |i| i['name'] }
    expect(institution_names).to include('Harvard University')
  end

  it "creates a new affiliate" do
    expect {
      post :create, affiliation: { name: "new", email: "email@example.com", user_id: user_id }
    }.to change { Affiliation.count }.by(1)
  end

  it "correctly sets a new affiliate email address" do
    post :create, affiliation: { name: "new", email: "email@example.com", user_id: user_id }
    expect(Affiliation.find_by(name: "new").email).to eq("email@example.com")
  end

  it "destroys an existing affiliate" do
    affiliation = FactoryGirl.create(:affiliation, user: user)
    expect {
      delete :destroy, id: affiliation.id
    }.to change { Affiliation.count }.by(-1)
  end
end
