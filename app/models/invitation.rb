class Invitation < ActiveRecord::Base
  include EventStream::Notifiable
  include AASM

  belongs_to :task
  belongs_to :decision
  has_one :paper, through: :task
  belongs_to :invitee, class_name: 'User', inverse_of: :invitations
  belongs_to :inviter, class_name: 'User', inverse_of: :invitations_from_me
  belongs_to :actor, class_name: 'User'
  before_create :assign_to_latest_decision

  scope :where_email_matches,
        ->(email) { where('lower(email) = lower(?) OR lower(email) like lower(?)', email, "%<#{email}>") }

  before_validation :set_invitee_role
  validates :invitee_role, presence: true

  aasm column: :state do
    state :pending, initial: true
    state :invited do
      validates :invitee, presence: true
    end
    state :accepted
    state :rejected

    # We add guards for each state transition, as a way for tasks to optionally
    # block a certain transition if desired.

    event(:invite,
          after: :associate_existing_user,
          after_commit: :notify_invitation_invited) do
      transitions from: :pending, to: :invited, guards: :invite_allowed?
    end
    event(:accept, {
      after_commit: :notify_invitation_accepted
    }) do
      transitions from: :invited, to: :accepted, guards: :accept_allowed?
    end
    event(:reject, {
      after_commit: :notify_invitation_rejected
    }) do
      transitions from: :invited, to: :rejected, guards: :reject_allowed?
    end
  end

  def self.find_uninvited_users_for_paper(possible_users, paper)
    invited_users = where(
      decision_id: paper.decisions.latest.id,
      state: ["invited", "accepted", "rejected"]
    ).includes(:invitee).map(&:invitee)
    possible_users - invited_users
  end

  def recipient_name
    return invitee.full_name if invitee
    email
  end

  def rescind!
    destroy!.tap do
      task.invitation_rescinded(self)
    end
  end

  def email=(new_email)
    super(new_email.strip)
  end

  private

  def assign_to_latest_decision
    self.decision = paper.decisions.latest
  end

  def add_authors_to_information(invitation)
    authors_list = TahiStandardTasks::AuthorsList.authors_list(paper)
    return unless authors_list.present?
    invitation.update! information:
      "Here are the authors on the paper:\n\n#{authors_list}"
  end

  def notify_invitation_invited
    add_authors_to_information(self)
    task.invitation_invited(self)
  end

  def notify_invitation_accepted
    task.invitation_accepted(self)
  end

  def notify_invitation_rejected
    task.invitation_rejected(self)
  end

  def associate_existing_user
    update(invitee: User.find_by(email: email))
  end

  def invite_allowed?
    task.invite_allowed?(self)
  end

  def accept_allowed?
    task.accept_allowed?(self)
  end

  def reject_allowed?
    task.reject_allowed?(self)
  end

  def event_stream_serializer(user: nil)
    InvitationIndexSerializer.new(self, root: "invitation")
  end

  def set_invitee_role
    self.invitee_role = task.invitee_role if task
  end
end
