require 'rails_helper'

describe DiscussionReply::Created::NotifyPeopleMentioned do
  include EventStreamMatchers

  let(:user) { FactoryGirl.create(:user) }

  it 'sends a notification to a person @mentioned in the discussion' do
    Subscriptions.reload
    expect(DiscussionReply::Created::NotifyPeopleMentioned).to receive(:call)
    FactoryGirl.create(:discussion_reply, body: "Interesting point @#{user.username}")
  end
end

