require 'rails_helper'

describe UserInboxesController do

  let(:user) { create :user }
  let(:inbox) { Notifications::UserInbox.new(user.id) }

  before do
    sign_in user
  end

  describe "#index" do
    let(:collapser) { double(:discard! => true, latest_activities: ["fake_activity"]) }
    before do
      allow(controller).to receive(:collapser).and_return(collapser)
    end

    it "returns a 200" do
      response = get(:index, format: :json)
      expect(response.status).to eq(200)
    end

    it "returns the latest activities in the user's inbox" do
      expect(collapser).to receive(:latest_activities)

      response = get(:index, format: :json)
      expect(JSON.parse(response.body)["user_inboxes"]).to match_array(["fake_activity"])
    end

    it "discards older activities" do
      expect(collapser).to receive(:discard!)

      get(:index, format: :json)
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
