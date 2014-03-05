require 'spec_helper'

describe UserSettingsController do
  let(:user) { FactoryGirl.create :user }

  before { sign_in user }

  describe "POST 'update'" do
    context "without a flow" do
      subject(:do_request) do
        # jQuery will not send empty object params, {} or [], e.g
        patch :update
      end

      specify { expect(do_request).to be_success }

      it_behaves_like "when the user is not signed in"

      it "updates the user's flow preferences" do
        expect { do_request }.to change { user.reload.user_settings.flows }.to []
      end
    end

    context "with a flow" do
      subject(:do_request) do
        patch :update, flows: ['Up for grabs']
      end

      specify { expect(do_request).to be_success }

      it_behaves_like "when the user is not signed in"

      it "updates the user's flow preferences" do
        expect { do_request }.to change { user.reload.user_settings.flows }.to ['Up for grabs']
      end
    end
  end
end
