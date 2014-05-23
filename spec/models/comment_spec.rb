require 'spec_helper'

describe Comment do
  describe 'callbacks' do
    let(:participant) { create :user }
    let(:commenter) { create :user }
    let(:message_task) { create :message_task, participants: [commenter, participant], phase_id: 1 }
    let(:comment) { message_task.comments.create! body: "Halo", message_task: message_task, commenter: commenter }
  end
end
