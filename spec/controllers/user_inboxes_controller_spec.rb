require 'rails_helper'

describe UserInboxesController do

  let(:user) { create :user }
  let(:inbox) { Notifications::UserInbox.new(user.id) }

  before do
    sign_in user
  end

  describe "#index" do
    it "returns a 204" do
      response = get(:index, format: :json)
      expect(response.status).to eq(204)
    end
  end

  describe "#destroy" do
    context "an existing activity in the inbox" do
      before { inbox.set([33, 55]) }

      it "destroys only the specified inbox record" do
        response = put(:destroy, format: :json, id: 33)
        expect(inbox.get).to eq(["55"])
        expect(response.status).to eq(204)
      end
    end

    context "a non-existing activity in the inbox" do
      before { inbox.set([33, 55]) }

      it "returns a 204" do
        response = put(:destroy, format: :json, id: 9999)
        expect(response.status).to eq(204)
      end
    end
  end
end
