require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      redirect_to "/"
    end
  end

  let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee:nil) }
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
      sign_in user
      expect(invitation.invitee).to eq nil
      get :index
    end

    context "and the invitation is open" do
      it "associates current user with the right invitation" do
        expect(invitation.reload.invitee).to eq user
      end
    end

    context "and the invitation is not open" do
      let(:invitation) { FactoryGirl.create(:invitation, :accepted, invitee:nil) }

      it "does not associate the current user with invitation " do
        expect(invitation.reload.invitee).to be nil
      end
    end
  end

end
