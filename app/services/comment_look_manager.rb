class CommentLookManager
  def self.sync(task)
    task.participants.each do |participant|
      task.comments.each do |comment|
        read_at = Time.now if comment.created_by?(participant)
        comment.comment_looks.where(user_id: participant.id).first_or_create!(read_at: read_at)
      end
    end
  end
end
