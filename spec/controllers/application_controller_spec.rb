require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      redirect_to "/"
    end
  end

  let(:invitation_code) { "12345" }

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

end
