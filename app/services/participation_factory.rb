class ParticipationFactory
  attr_reader :task, :assignee, :assigner
  attr_accessor :notify

  def self.create(task:, assignee:, assigner: nil, notify: true)
    new(task: task, assignee: assignee, assigner: assigner, notify: notify).save
  end

  def initialize(task:, assignee:, assigner:, notify:)
    @task = task
    @assignee = assignee
    @assigner = assigner
    @notify = notify
  end

  def save
    return if task.participants.include?(assignee)
    self.notify = false if self_assigned?
    create_participation
  end

  private

  def create_participation
    # New roles
    task.participations.create!(
      user: assignee,
      role: task.journal.roles.participant
    )

    # Old roles
    Participation.create!(
      task: task,
      user: assignee,
      notify_requester: self_assigned?
    ).tap do
      send_notification if notify
      CommentLookManager.sync_task(task)
    end
  end

  def self_assigned?
    assigner == assignee
  end

  def send_notification
    UserMailer.delay.add_participant(assigner.try(:id), assignee.id, task.id)
  end
end
