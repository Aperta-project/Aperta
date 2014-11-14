require 'spec_helper'

describe EventStream do
  describe "#post" do
    let(:users) { FactoryGirl.create_list(:user, 2) }
    let(:resource) { FactoryGirl.create(:paper) }
    let(:stream) { EventStream.new("created", resource, "paper:created") }

    before do
      allow_any_instance_of(Accessibility).to receive(:users).and_return(users)
    end

    it "finds the appropriate users" do
      expect(Accessibility).to receive(:new).with(resource).and_call_original
      stream.post
    end

    it "sends a payload for the appropriate users" do
      expect(EventStreamConnection).to receive(:post_user_event).exactly(2).times
      stream.post
    end
  end

  describe "#destroy" do
    let(:resource) { FactoryGirl.create(:task) }
    let(:stream) { EventStream.new("destroyed", resource, "task:destroyed") }

    it "sends one destroy payload to the system channel" do
      expect(EventStreamConnection).to receive(:post_system_event).once
      stream.destroy
    end
  end
end
