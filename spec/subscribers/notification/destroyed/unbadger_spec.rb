require 'rails_helper'

describe Notification::Unbadger do
  include EventStreamMatchers

  it 'sends a notification to a person removed from a discussion' do
    participant = FactoryGirl.create(:discussion_participant)
    participant.save!
    Subscriptions.reload
    expect(Notification::Unbadger).to receive(:call)
    participant.destroy!
  end
end
