class TaskRoleUpdater
  attr_accessor :role_task, :paper, :user, :role

  def initialize(role_task, user_id, role)
    @role_task = role_task
    @paper = role_task.paper
    @user = User.find(user_id)
    @role = role
  end

  def update
    paper.transaction do
      paper.assign_role!(user, role)
      related_tasks.each do |task|
        ParticipationFactory.create(task, user)
      end
    end
  end

  private

  def related_tasks
    paper.tasks.without(role_task).for_role(role).incomplete
  end
end
