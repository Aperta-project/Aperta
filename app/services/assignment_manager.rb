class AssignmentManager

  attr_accessor :task, :previous_assignee_id, :assigner_id

  def initialize(task, assigner)
    @task = task
    @previous_assignee_id = task.previous_changes["assignee_id"].try(:first)
    @assigner_id = assigner.try(:id)
  end

  def sync
    return unless task.assignee.present?

    if assignee_changed? && !task.participants.include?(task.assignee)
      task.participants << task.assignee
      UserMailer.delay.add_participant(assigner_id, task.assignee_id, task.id)
      CommentLookManager.sync_task(task)
    end

    if email_eligible?
      UserMailer.delay.assign_task(assigner_id, task.assignee_id, task.id)
    end
  end

  private

  def email_eligible?
    assignee_changed? && task.assignee.id != assigner_id
  end

  def assignee_changed?
    previous_assignee_id.present?
  end
end
