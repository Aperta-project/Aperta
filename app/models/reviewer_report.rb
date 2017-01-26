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
        invitation.state
      end
    else
      "not_invited"
    end
  end
end
