require 'spec_helper'

describe Comment do
  describe 'create_with_comment_look' do
    let(:participant) { create :user }
    let(:commenter) { create :user }
    let(:message_task) { create :message_task, participants: [commenter, participant], phase_id: 1 }
    let(:comment) { message_task.comments.create_with_comment_look(message_task, {body: "Halo", task: message_task, commenter: commenter}) }
    let(:comment_look) { comment.comment_looks.first }

    it 'creates comment looks for each comment and participant except commenter' do
      expect(comment.comment_looks.count).to eq(1)
    end

    it 'creates comment look records for each participant except commenter' do
      expect(comment.comment_looks.map(&:user)).to match_array [participant]
    end
  end
end
