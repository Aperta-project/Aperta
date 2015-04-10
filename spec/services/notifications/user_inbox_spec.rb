require "rails_helper"

describe Notifications::UserInbox do

  let(:user) { FactoryGirl.create(:user) }
  let(:inbox) { Notifications::UserInbox.new(user.id) }

  describe "#set" do
    it "will set a single value" do
      inbox.set("999")
      expect(inbox.get).to include("999")
    end

    it "will set multiple values" do
      inbox.set(["111", "999"])
      expect(inbox.get).to include("111", "999")
    end
  end

  describe "#get" do
    before { inbox.set(["111", "999"]) }

    it "will get all values" do
      expect(inbox.get).to eq(["111", "999"])
    end
  end

  describe "#remove" do
    before { inbox.set(["111", "999"]) }

    it "will only remove the value passed" do
      inbox.remove("111")
      expect(inbox.get).to eq(["999"])
    end

    it "will remove multiple values" do
      inbox.remove(["111", "999"])
      expect(inbox.get).to be_empty
    end
  end
end
