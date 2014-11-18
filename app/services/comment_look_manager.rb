class CommentLookManager
  def self.sync_task(task)
    task.comments.map do |comment|
      sync_comment(comment)
    end
  end

  def self.sync_comment(comment)
    comment.transaction do
      comment.save!
      comment.task.participants.each do |user|
        create_comment_look(user, comment)
      end
    end
  end

  def self.create_comment_look(user, comment)
    return unless user.present?

    participation = user.participations.find_by_task_id(comment.task_id)
    if participation && comment.created_at >= participation.created_at
      read_at = Time.now if comment.created_by?(user)
      comment.comment_looks.where(user_id: user.id).first_or_create!(read_at: read_at)
    end
  end
end
