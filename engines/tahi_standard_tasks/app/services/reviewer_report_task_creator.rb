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
      task = TahiStandardTasks::ReviewerReportTask.create!(
        paper: paper,
        phase: default_phase,
        old_role: PaperRole::REVIEWER,
        title: "Review by #{assignee.full_name}"
      )

      Assignment.where(
        user: assignee,
        role: paper.journal.task_participant_role,
        assigned_to: task
      ).first_or_create!

      ParticipationFactory.create(task: task, assignee: assignee, notify: false)
      TahiStandardTasks::ReviewerMailer
        .delay.welcome_reviewer(assignee_id: assignee.id,
                                task_id: task.id)
    else
      existing_reviewer_report_task.incomplete!
    end
  end

  def existing_reviewer_report_task
    @existing_reviewer_report_task ||= begin
      TahiStandardTasks::ReviewerReportTask.joins(assignments: :role).where(
        paper_id: paper.id,
        assignments: {
          role_id: paper.journal.task_participant_role, user_id: assignee.id
        }
      ).first
    end
  end

  # multiple `assignee` can exist on `paper` as a reviewer
  def assign_paper_role!
    Assignment.where(
      user: assignee,
      role: paper.journal.reviewer_role,
      assigned_to: paper
    ).first_or_create!
  end

  def default_phase
    paper.phases.where(name: 'Get Reviews').first || originating_task.phase
  end
end
