class ParticipationFactory
  def self.create(task, user)
    unless task.participants.include?(user)
      task.participants << user
      UserMailer.delay.add_participant(nil, user.id, task.id)
      CommentLookManager.sync_task(task)
    end
  end
end
