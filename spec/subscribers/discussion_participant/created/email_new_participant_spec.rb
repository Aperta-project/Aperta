require 'rails_helper'

describe DiscussionParticipant::Created::EmailNewParticipant do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:participant) { FactoryGirl.create(:discussion_participant) }
  let!(:current_user) { FactoryGirl.create(:user) }

  it 'sends an email to people added to discussions' do
    expect(mailer).to receive(:notify_added_to_topic).with(
        participant.user_id,
        current_user.id,
        participant.discussion_topic_id
    )
    described_class.call(
      'tahi:discussion_participant:created',
      record: participant,
      current_user_id: current_user.id
    )
  end

  context 'the new participant is the current user' do
    it 'does not send an email' do
      expect(mailer).to_not receive(:notify_added_to_topic)
      described_class.call(
        'tahi:discussion_participant:created',
        record: participant,
        current_user_id: participant.id
      )
    end
  end
end
