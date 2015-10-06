require 'rails_helper'

describe QuestionAttachment::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:question_attachment) { FactoryGirl.build(:question_attachment_with_task_owner) }

  it "serializes question_attachment down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :question_attachment, down: 'paper', on: 'created')
    described_class.call("tahi:question_attachment:created", { action: "created", record: question_attachment })
  end

end
