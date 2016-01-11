require 'rails_helper'

RSpec.describe DiscussionReply, type: :model, redis: true do
  include ActiveJob::TestHelper

  context 'with an @mention' do
    before { ActionMailer::Base.deliveries.clear }
    after  { clear_enqueued_jobs }

    it 'sends an email' do
      user = FactoryGirl.create(:user)
      body = "What do you think @#{user.username}?"
      paper = FactoryGirl.create(:paper)
      topic = FactoryGirl.create(:discussion_topic, paper: paper)
      FactoryGirl.create(:discussion_reply, discussion_topic: topic, body: body)

      expect(enqueued_jobs.size).to eq 1
    end
  end
end
