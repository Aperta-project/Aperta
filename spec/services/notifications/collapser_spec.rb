require "rails_helper"

describe Notifications::Collapser do
  let(:user) { FactoryGirl.create(:user) }
  let(:inbox) { Notifications::UserInbox.new(user.id) }

  context "two unread events with different event names" do
    let(:activity_1) { FactoryGirl.create(:activity, event_name: "paper::explosion") }
    let(:activity_2) { FactoryGirl.create(:activity, event_name: "paper::something_happened") }
    let(:collapser) { Notifications::Collapser.new(user: user, event_names: ["paper::explosion", "paper::something_happened"]) }

    before { inbox.set([activity_1.id, activity_2.id]) }

    it "returns both activities for #unread_activities" do
      expect(collapser.unread_activities).to include(activity_1, activity_2)
    end

    it "returns both for #latest_activities" do
      expect(collapser.latest_activities).to include(activity_1, activity_2)
    end

    it "returns empty array for #superceded_activities" do
      expect(collapser.superceded_activities).to be_empty
    end

    it "does not remove from inbox when #discard!" do
      expect {
        collapser.discard!
      }.to change { inbox.get.size }.by(0)
    end
  end


  context "two unread events with the same event name and target" do
    let(:activity_1) { FactoryGirl.create(:activity, event_name: "paper::explosion", created_at: 5.minutes.ago) }
    let(:activity_2) { FactoryGirl.create(:activity, target: activity_1.target, event_name: "paper::explosion", created_at: Time.now) }
    let(:collapser) { Notifications::Collapser.new(user: user, event_names: ["paper::explosion"]) }

    before { inbox.set([activity_1.id, activity_2.id]) }

    it "returns both activities for #unread_activities" do
      expect(collapser.unread_activities).to include(activity_1, activity_2)
    end

    it "returns most recent activity for #latest_activities" do
      expect(collapser.latest_activities).to eq([ activity_2 ])
    end

    it "returns oldest activity for #superceded_activities" do
      expect(collapser.superceded_activities).to eq([ activity_1 ])
    end

    it "removes oldest activity when #discard!" do
      collapser.discard!
      expect(inbox.get).to eq([activity_2.id.to_s])
    end
  end


  context "two unread events with the same event name and different targets" do
    let(:activity_1) { FactoryGirl.create(:activity, event_name: "paper::explosion", created_at: 5.minutes.ago) }
    let(:activity_2) { FactoryGirl.create(:activity, event_name: "paper::explosion", created_at: Time.now) }
    let(:collapser) { Notifications::Collapser.new(user: user, event_names: ["paper::explosion"]) }

    before { inbox.set([activity_1.id, activity_2.id]) }

    it "returns both activities for #unread_activities" do
      expect(collapser.unread_activities).to include(activity_1, activity_2)
    end

    it "returns both for #latest_activities" do
      expect(collapser.latest_activities).to include(activity_1, activity_2)
    end

    it "returns empty array for #superceded_activities" do
      expect(collapser.superceded_activities).to be_empty
    end

    it "does not remove from inbox when #discard!" do
      expect {
        collapser.discard!
      }.to change { inbox.get.size }.by(0)
    end
  end
end
