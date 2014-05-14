require 'spec_helper'

describe Comment do
  describe 'callbacks' do
    let(:participant) { create :user }
    let(:commenter) { create :user }
    let(:message_task) { create :message_task, participants: [commenter, participant], phase_id: 1 }
    let(:comment) { message_task.comments.create! body: "Halo" }
    let(:comment_look) { comment.comment_looks.first }

    it 'creates comment looks for each comment and participant' do
      expect(comment.comment_looks.count).to eq(2)
    end

    it 'creates comment look records for each participant' do
      expect(comment.comment_looks.map(&:user)).to match_array [commenter, participant]
    end
  end
end
