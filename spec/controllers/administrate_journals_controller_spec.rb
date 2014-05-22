require 'spec_helper'

describe AdministrateJournalsController do

  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :admin) }
  before { sign_in user }

  it "will allow access" do
    get :index, format: :json
    expect(response.status).to eq(200)
  end
end
