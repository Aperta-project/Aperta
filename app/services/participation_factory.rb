class ParticipationFactory
  def self.create(task:, assignee:, assigner: nil)
    new(task: task, assignee: assignee, assigner: assigner).save
  end

  attr_reader :task, :assignee, :assigner

  def initialize(task:, assignee:, assigner:)
    @task = task
    @assignee = assignee
    @assigner = assigner
  end

  def save
    return if task.participants.include?(assignee)

    Participation.create(task: task, user: assignee, notify_requester: self_assigned?).tap do |_|
      UserMailer.delay.add_participant(assigner.try(:id), assignee.id, task.id) unless self_assigned?
      CommentLookManager.sync_task(task)
    end
  end


  private

  def self_assigned?
    assigner == assignee
  end
end
