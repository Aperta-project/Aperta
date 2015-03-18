require 'rails_helper'

describe UserInboxesController do

  let(:user) { create :user }
  let(:inbox) { Notifications::UserInbox.new(user.id) }

  before do
    sign_in user
  end

  describe "#index" do
    context "two unread events with different event names" do
      let(:activity_1) { FactoryGirl.create(:activity, event_name: "paper::explosion") }
      let(:activity_2) { FactoryGirl.create(:activity, event_name: "paper::something_happened") }

      before { inbox.set([activity_1.id, activity_2.id]) }

      it "returns both events" do
        expect(TahiNotifier).to receive(:notify).twice
        get(:index, format: :json, event_names: ["paper::explosion", "paper::something_happened"])
      end
    end

    context "two unread events with the same event name and target" do
      let(:activity_1) { FactoryGirl.create(:activity, event_name: "paper::explosion") }
      let(:activity_2) { FactoryGirl.create(:activity, target: activity_1.target, event_name: "paper::explosion") }

      before { inbox.set([activity_1.id, activity_2.id]) }

      it "returns both events collapsed into one" do
        expect(TahiNotifier).to receive(:notify).once
        get(:index, format: :json, event_names: ["paper::explosion", "paper::something_happened"])
      end

      it "destroys the older collapsed activity" do
        expect {
          get(:index, format: :json, event_names: ["paper::explosion", "paper::something_happened"])
        }.to change{ inbox.get.size }.by(-1)
      end
    end
  end

  describe "#destroy" do
    context "an existing activity in the inbox" do
      before { inbox.set([33, 55]) }

      it "destroys only the specified inbox record" do
        response = put(:destroy, format: :json, id: 33)
        expect(inbox.get).to include("55")
        expect(inbox.get).to_not include("33")
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
