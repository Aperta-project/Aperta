require 'spec_helper'

describe AffiliationsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it "returns a list of the institution names" do
    get :index
    expect(JSON.parse(response.body)['institutions']).to include('Harvard University')
  end

  it "creates a new affiliate" do
    expect{
      post :create, affiliation: { name: "new", email: "email@example.com" }
    }.to change{ Affiliation.count }.by(1)
  end
end
