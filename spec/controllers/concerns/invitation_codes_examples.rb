require 'rails_helper'

RSpec.shared_examples_for "controller supports invitation codes" do
  let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee:nil) }
  let(:user) { FactoryGirl.create(:user) }

  describe "handling invitation codes" do
    shared_examples_for "controller handles an invalid invitation_code" do
      it "does not set invitation code in the session" do
        expect(session["invitation_code"]).to eq nil
      end

      it "sets a flash[:alert] message for the user" do
        expect(flash[:alert]).to eq "The invitation is no longer active or has expired."
      end
    end

    context "without an ?invitation_code" do
      it "does not set invitation code in the session" do
        get :index
        expect(session["invitation_code"]).to eq nil
      end
    end

    context "with a bad ?invitation_code" do
      before do
        get :index, invitation_code: "some-made-up-invitation-code"
      end

      include_examples "controller handles an invalid invitation_code"
    end

    context "with an ?invitation_code for an Invitation no longer in the 'invited' state" do
      before do
        invitation.update_attribute :state, 'accepted'
        get :index, invitation_code: "some-made-up-invitation-code"
      end

      include_examples "controller handles an invalid invitation_code"
    end

    context "with an ?invitation_code tied to an 'invited' Invitation" do
      it "sets the invitation code in the session" do
        get :index, invitation_code: invitation.code
        expect(session["invitation_code"]).to eq invitation.code
      end
    end
  end

  describe "associating a user with an invitation code" do
    before do
      expect(invitation.invitee).to eq nil
    end

    context "and the user is signed in previous to using the invitation_code" do
      before do
        sign_in user
        get :index, invitation_code: invitation.code
      end

      it "associates current user with the right invitation" do
        expect(invitation.reload.invitee).to eq user
      end

      it "clears the invitation_code from the session" do
        expect(session[:invitation_code]).to be(nil)
      end
    end

    context "and signs in after using the invitation_code" do
      before do
        get :index, invitation_code: invitation.code
        sign_in user
        get :index
      end

      it "associates current user with the right invitation" do
        expect(invitation.reload.invitee).to eq user
      end

      it "clears the invitation_code from the session" do
        expect(session[:invitation_code]).to be(nil)
      end
    end

    context "and the invitation has already been used" do
      let(:invitation) { FactoryGirl.create(:invitation, :accepted, invitee: nil) }

      before do
        sign_in user
        get :index, invitation_code: invitation.code
      end

      it "does not associate the current user with invitation " do
        expect(invitation.reload.invitee).to be nil
      end

      it "clears the invitation_code from the session" do
        expect(session[:invitation_code]).to be(nil)
      end
    end
  end
end
