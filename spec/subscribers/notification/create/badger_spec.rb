require 'rails_helper'

describe Notification::Badger do
  include EventStreamMatchers

  it 'sends a notification to a person added as a participation to the discussion' do
    Subscriptions.reload
    expect(Notification::Badger).to receive(:call)
    FactoryGirl.create(:discussion_participant)
  end
end
