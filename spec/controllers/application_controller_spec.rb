require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      redirect_to "/"
    end
  end

  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:invitation_code) { invitation.code }
  let(:user) { FactoryGirl.create(:user) }

  describe "#set_invitation_code" do
    context "without an ?invitation_code" do
      it "does not set invitation code" do
        get :index

        expect(session["invitation_code"]).to eq nil
      end
    end

    context "with an ?invitation_code" do
      it "sets invitation code in the session" do
        get :index, invitation_code: invitation_code
        expect(session["invitation_code"]).to eq invitation_code
      end
    end
  end

  describe "#associate_user_with_invitation" do
    before do
      session["invitation_code"] = invitation_code
      invitation.update(invitee: nil)
    end

    it "associates current user with invitation_code to the " do
      sign_in user
      expect(invitation.invitee).to eq nil
      get :index

      expect(invitation.reload.invitee).to eq user
    end
  end

end
