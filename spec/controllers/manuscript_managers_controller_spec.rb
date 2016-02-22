require 'rails_helper'

describe ManuscriptManagersController do
  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end
  before { sign_in user }

  it "will allow access" do
    get :show, { paper_id: paper.to_param }
    expect(response.status).to eq(200)
  end
end
