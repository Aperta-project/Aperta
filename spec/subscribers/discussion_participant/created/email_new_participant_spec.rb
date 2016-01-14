require 'rails_helper'

describe DiscussionParticipant::Created::EmailNewParticipant do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:participant) { FactoryGirl.create(:discussion_participant) }

  it 'sends an email to people added to discussions' do
    expect(mailer).to receive(:notify_added_to_topic)
      .with(participant.user_id, participant.discussion_topic_id)
    described_class.call('tahi:discussion_participant:created',
                         record: participant)
  end
end
