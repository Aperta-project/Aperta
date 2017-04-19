# This class represents the reviewer reports per decision round
class ReviewerReport < ActiveRecord::Base
  include Answerable
  include NestedQuestionable
  include AASM

  default_scope { order('decision_id DESC') }

  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision

  validates :task,
    uniqueness: { scope: [:task_id, :user_id, :decision_id],
                  message: 'Only one report allowed per reviewer per decision' }

  def self.for_invitation(invitation)
    reports = ReviewerReport.where(user: invitation.invitee,
                                   decision: invitation.decision)
    if reports.count > 1
      raise "More than one reviewer report for invitation (#{invitation.id})"
    end
    reports.first
  end

  aasm column: :state do
    state :invitation_not_accepted, initial: true
    state :review_pending
    state :submitted

    event(:accept_invitation,
          guards: [:invitation_accepted?]) do
      transitions from: :invitation_not_accepted, to: :review_pending
    end

    event(:rescind_invitation) do
      transitions from: [:invitation_not_accepted, :review_pending],
                  to: :invitation_not_accepted
    end

    event(:submit,
          guards: [:invitation_accepted?], after: [:set_submitted_at]) do
      transitions from: :review_pending, to: :submitted
    end
  end

  def invitation
    @invitation ||= decision.invitations.find_by(invitee_id: user.id)
  end

  def invitation_accepted?
    invitation && invitation.accepted?
  end

  def revision
    # if a decision has a revision, use it, otherwise, use paper's
    major_version = decision.major_version || task.paper.major_version || 0
    minor_version = decision.minor_version || task.paper.minor_version || 0
    "v#{major_version}.#{minor_version}"
  end

  # this is a convenience method that's called by
  # NestedQuestionAnswersController#fetch_answer and a few other places
  def paper
    task.paper
  end

  def computed_status
    case aasm.current_state
    when STATE_INVITATION_NOT_ACCEPTED
      compute_invitation_state
    when STATE_REVIEW_PENDING
      "pending"
    when STATE_SUBMITTED
      "completed"
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def computed_datetime
    case computed_status
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
    when "completed"
      submitted_at
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  def set_submitted_at
    update!(submitted_at: Time.current.utc)
  end

  def compute_invitation_state
    if invitation
      "invitation_#{invitation.state}"
    else
      "not_invited"
    end
  end
end
