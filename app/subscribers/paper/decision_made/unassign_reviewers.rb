# Rescinds any in-flight reviewer invitations when a decision is made.
# Reviewers are also unassigned from the paper, but that
# process is owned by Paper::DecisionMade::UnassignReviewers
# which lives in the main app.
class Paper::DecisionMade::UnassignReviewers
  REVIEWER_SPECIFIC_TASKS = ["TahiStandardTasks::FrontMatterReviewerReportTask",
                             "TahiStandardTasks::ReviewerReportTask"]

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    invalidate_invitations(paper)
    unassign_reviewers(paper)
  end

  def self.invalidate_invitations(paper)
    invitations = Invitation.joins(:task).where(
      'tasks.paper_id' => paper.id,
      'tasks.type' => 'TahiStandardTasks::PaperReviewerTask',
      'invitations.state' => 'invited')

    invitations.each(&:rescind!)
  end

  def self.unassign_reviewers(paper)
    participant_role = paper.journal.task_participant_role
    reviewer_role = paper.journal.reviewer_role
    reviewer_tasks = paper.tasks.where(type: REVIEWER_SPECIFIC_TASKS)

    paper.reviewers.each do |reviewer|
      reviewer.resign_from!(
        assigned_to: reviewer_tasks,
        role: participant_role
      )
      reviewer.resign_from!(assigned_to: paper, role: reviewer_role)
    end
  end
end
