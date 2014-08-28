class CommentLookManager
  def self.sync(task)
    task.participants.each do |participant|
      task.comments.each do |comment|
        comment.comment_looks.first_or_create(user_id: participant.id)
      end
    end
  end
end
