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
    if existing_reviewer_report_task.blank?
      task = reviewer_report_task_class.create!(
        paper: paper,
        phase: default_phase,
        old_role: PaperRole::REVIEWER,
        title: "Review by #{assignee.full_name}"
      )
      assignee.assign_to!(assigned_to: task, role: paper.journal.task_participant_role)
      assignee.assign_to!(assigned_to: task, role: paper.journal.reviewer_report_owner_role)

      ParticipationFactory.create(task: task, assignee: assignee, notify: false)
      TahiStandardTasks::ReviewerMailer
        .delay.welcome_reviewer(assignee_id: assignee.id,
                                paper_id: paper.id)
      task
    else
      assignee.assign_to!(assigned_to: existing_reviewer_report_task,
                          role: paper.journal.task_participant_role)
      existing_reviewer_report_task.tap(&:incomplete!)
    end
  end

  def reviewer_report_task_class
    if @paper.uses_research_article_reviewer_report
      TahiStandardTasks::ReviewerReportTask
    else
      TahiStandardTasks::FrontMatterReviewerReportTask
    end
  end

  def existing_reviewer_report_task
    @existing_reviewer_report_task ||= begin
      reviewer_report_task_class.joins(assignments: :role).where(
        paper_id: paper.id,
        assignments: {
          role_id: paper.journal.reviewer_report_owner_role,
          user_id: assignee.id
        }
      ).first
    end
  end

  # Multiple assignees can exist on `paper` as a reviewer
  def assign_paper_role!
    assignee.assign_to!(assigned_to: paper, role: paper.journal.reviewer_role)
  end

  def default_phase
    paper.phases.where(name: 'Get Reviews').first || originating_task.phase
  end
end
