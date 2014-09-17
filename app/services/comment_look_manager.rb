class CommentLookManager
  def self.comment_looks(comment)
    comment.participants.map do |participant|
      read_at = Time.now if comment.created_by?(participant)
      comment.comment_looks.where(user_id: participant.id).first_or_create!(read_at: read_at)
    end
  end
end
