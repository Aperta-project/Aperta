class ReviewerReportTaskCreator
  attr_accessor :originating_task, :paper, :assignee, :paper_role_name

  def initialize(originating_task:, assignee_id:, paper_role_name:)
    @originating_task = originating_task
    @paper = originating_task.paper
    @assignee = User.find(assignee_id)
    @paper_role_name = paper_role_name
  end

  def process
    paper.transaction do
      assign_paper_role!
      create_related_task!
    end
  end

  private

  def create_related_task!
    task = TahiStandardTasks::ReviewerReportTask.create!(phase: default_phase,
                      role: PaperRole::REVIEWER,
                      title: "Review by #{assignee.full_name}")
    ParticipationFactory.create(task, assignee)
  end

  # multiple `assignee` can exist on `paper` with the same `paper_role_name`
  def assign_paper_role!
    paper.paper_roles.for_role(paper_role_name).create!(user: assignee)
  end

  def default_phase
    paper.phases.where(name: 'Get Reviews').first || originating_task.phase
  end
end
