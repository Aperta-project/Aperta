require 'rails_helper'

describe AffiliationsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it "returns a list of the institution names" do
    get :index, query: "Harvard"
    institution_names = res_body['institutions'].map { |i| i['name'] }
    expect(institution_names).to include('Harvard University')
  end

  it "creates a new affiliate" do
    expect {
      post :create, affiliation: { name: "new", email: "email@example.com" }
    }.to change { Affiliation.count }.by(1)
  end

  it "correctly sets a new affiliate email address" do
    post :create, affiliation: { name: "new", email: "email@example.com" }
    expect(Affiliation.find_by(name: "new").email).to eq("email@example.com")
  end

  it "destroys an existing affiliate" do
    affiliation = FactoryGirl.create(:affiliation, user: user)
    expect {
      delete :destroy, id: affiliation.id
    }.to change { Affiliation.count }.by(-1)
  end
end
