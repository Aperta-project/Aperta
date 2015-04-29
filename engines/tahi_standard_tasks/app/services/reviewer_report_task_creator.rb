class ReviewerReportTaskCreator
  attr_accessor :originating_task, :paper, :assignee

  def initialize(originating_task:, assignee_id:)
    @originating_task = originating_task
    @paper = originating_task.paper
    @assignee = User.find(assignee_id)
  end

  def process
    paper.transaction do
      assign_paper_role!
      find_or_create_related_task
    end
  end

  private

  def find_or_create_related_task
    if existing_reviewer_report_task.empty?
      task = TahiStandardTasks::ReviewerReportTask.create!(phase: default_phase,
                        role: PaperRole::REVIEWER,
                        title: "Review by #{assignee.full_name}")

      ParticipationFactory.create(task, assignee)
    end
  end

  def existing_reviewer_report_task
    paper.tasks.includes(:participations).where type: "TahiStandardTasks::ReviewerReportTask", participations: { user_id: assignee.id }
  end

  # multiple `assignee` can exist on `paper` as a reviewer
  def assign_paper_role!
    paper.paper_roles.for_role(PaperRole::REVIEWER).first_or_create!(user: assignee)
  end

  def default_phase
    paper.phases.where(name: 'Get Reviews').first || originating_task.phase
  end
end
