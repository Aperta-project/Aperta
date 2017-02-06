class ReviewerReport < ActiveRecord::Base
  default_scope { order('decision_id DESC') }

  include NestedQuestionable
  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision

  validates :task,
    uniqueness: { scope: [:task_id, :user_id, :decision_id],
                  message: 'Only one report allowed per reviewer per decision' }

  def invitation
    decision.invitations.find_by(invitee_id: user.id)
  end

  # status will look at the reviewer, invitations and the submitted state of
  # this task to get an overall status for the review
  def status
    if invitation
      if invitation.state == "accepted"
        if task.completed
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
      invitation.recinded_at
    end
  end

  def revision
    # if a decision has a revision, use it, otherwise, use paper's
    major_version = decision.major_version || task.paper.major_version || 0
    minor_version = decision.minor_version || task.paper.minor_version || 0
    "v#{major_version}.#{minor_version}"
  end
end
