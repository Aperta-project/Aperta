require "rails_helper"

describe Notifications::Stream do

  let(:user) { FactoryGirl.create(:user) }
  let(:activity) { FactoryGirl.create(:activity) }
  let(:stream) { Notifications::Stream.new(activity: activity, user: user) }

  describe "#post" do
    it "will post payload" do
      expect(EventStreamConnection).to receive(:post_event)
      stream.post
    end
  end

end
