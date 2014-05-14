require 'spec_helper'

describe Comment do
  describe 'callbacks' do
    let(:participant) { create :user }
    let(:commenter) { create :user }
    let(:message_task) { create :message_task, participants: [commenter, participant], phase_id: 1 }
    let(:comment) { message_task.comments.create! body: "Halo" }
    let(:comment_view) { comment.comment_views.first }

    it 'creates comment views for each comment and participant' do
      expect(comment.comment_views.count).to eq(2)
    end

    it 'creates comment view records for each participant' do
      expect(comment.comment_views.map(&:user)).to match_array [commenter, participant]
    end
  end
end
