class ParticipationFactory
  def self.create(task:, assignee:, assigner: nil)
    unless task.participants.include?(assignee)
      task.participants << assignee
      unless assigner == assignee
        UserMailer.delay.add_participant(assigner.try(:id), assignee.id, task.id)
      end
      CommentLookManager.sync_task(task)
    end
  end
end
