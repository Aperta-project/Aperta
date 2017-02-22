class ReviewerReport < ActiveRecord::Base
  include Answerable
  include NestedQuestionable

  default_scope { order('decision_id DESC') }

  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision

  validates :task,
    uniqueness: { scope: [:task_id, :user_id, :decision_id],
                  message: 'Only one report allowed per reviewer per decision' }

  def invitation
    decision.invitations.find_by(invitee_id: user.id)
  end

  # This method encapsulates looking up the correctly-named card for a given
  # task and journal, which happens in both the ReviewerReportTaskCreator and
  # in the Paper::Submitted::CreateReviewerReports subscription
  def self.card_for_task(task)
    card_name = {
      "TahiStandardTasks::FrontMatterReviewerReportTask" => 'FrontMatterReviewerReport',
      "TahiStandardTasks::ReviewerReportTask" => 'ReviewerReport'}.fetch(task.class.name)
    Card.find_by!(name: card_name, journal: task.journal)
  end

  # status will look at the reviewer, invitations and the submitted state of
  # this task to get an overall status for the review
  def status
    if invitation
      if invitation.state == "accepted"
        if task.submitted?
          "completed"
        else
          "pending"
        end
      else
        "invitation_#{invitation.state}"
      end
    else
      "not_invited"
    end
  end

  def status_date
    case status
    when "completed"
      task.completed_at
    when "pending"
      invitation.accepted_at
    when "invitation_invited"
      invitation.invited_at
    when "invitation_accepted"
      invitation.accepted_at
    when "invitation_declined"
      invitation.declined_at
    when "invitation_rescinded"
      invitation.rescinded_at
    end
  end

  def revision
    # if a decision has a revision, use it, otherwise, use paper's
    major_version = decision.major_version || task.paper.major_version || 0
    minor_version = decision.minor_version || task.paper.minor_version || 0
    "v#{major_version}.#{minor_version}"
  end

  # NestedQuestionable will save the paper_id to newly created answers if
  # an answer's owner responds to :paper
  def paper
    task.paper
  end
end
