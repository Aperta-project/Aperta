class CommentLookManager
  def self.sync_task(task)
    task.comments.map do |comment|
      sync_comment(comment)
    end
  end

  def self.sync_comment(comment)
    comment.transaction do
      comment.save!
      comment.notify_mentioned_people

      comment.task.participants.where.not(id: comment.commenter).each do |user|
        create_comment_look(user, comment)
      end
    end
  end

  def self.create_comment_look(user, comment)
    return unless user.present?
    return if comment.created_by?(user)

    participation = user.participations.find_by(assigned_to: comment.task)
    if participation && comment.created_at >= participation.created_at
      comment.comment_looks.where(user_id: user.id).first_or_create!
    end
  end
end
