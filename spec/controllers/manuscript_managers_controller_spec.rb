require 'spec_helper'

describe ManuscriptManagersController do

  expect_policy_enforcement

  let(:user) { create :user, :site_admin }
  let(:paper) { FactoryGirl.create(:paper, creator: user) }
  before { sign_in user }

  it "will allow access" do
    get :show, { paper_id: paper.to_param }
    expect(response.status).to eq(200)
  end
end
