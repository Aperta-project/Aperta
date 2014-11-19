require 'spec_helper'
describe UserFlowsController do

  expect_policy_enforcement
  authorize_policy(UserFlowsPolicy, true)

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#update" do
    subject(:do_request) do
      put :update, {
        format: 'json',
        id: flow.id,
        user_flow: {
          title: new_title
        }
      }
    end

    let!(:flow) { FactoryGirl.create(:user_flow, user: user, title: "My tasks") }

    context "title does not map to a template" do
      let(:new_title) { "Something that does not match" }

      it "returns head 422" do
        do_request
        expect(response.status).to eq(422)
      end
    end
  end
end
