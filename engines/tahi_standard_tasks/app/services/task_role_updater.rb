class TaskRoleUpdater
  attr_accessor :task, :paper, :assignee, :paper_role_name

  def initialize(task:, assignee_id:, paper_role_name:)
    @task = task
    @paper = task.paper
    @assignee = User.find(assignee_id)
    @paper_role_name = paper_role_name
  end

  def update
    paper.transaction do
      assign_paper_role!
      assign_related_tasks
    end
  end

  private

  def assign_related_tasks
    related_tasks.each do |task|
      ParticipationFactory.create(task: task, assignee: assignee)
    end
  end

  # only one `assignee` can exist on `paper` with the same `paper_role_name`
  def assign_paper_role!
    # New
    role = Role.for_old_role(paper_role_name, paper: paper)
    paper.assignments.where(role: role).destroy_all
    paper.assignments.create!(user: assignee, role: role)

    # Old
    paper.paper_roles.for_old_role(paper_role_name).destroy_all
    paper.paper_roles.for_old_role(paper_role_name).create!(user: assignee)
  end

  def related_tasks
    paper.tasks.for_old_role(paper_role_name).incomplete
  end
end
