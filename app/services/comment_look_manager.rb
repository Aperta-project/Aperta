class CommentLookManager
  def self.comment_look(user, comment)
    return unless user

    participation = user.participations.find_by_task_id(comment.task_id)
    if participation && comment.created_at >= participation.created_at
      read_at = Time.now if comment.created_by?(user)
      comment.comment_looks.where(user_id: user.id).first_or_create!(read_at: read_at)
    end
  end
end
