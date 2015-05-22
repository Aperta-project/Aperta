class Invitation < ActiveRecord::Base
  include EventStream::Notifiable
  include AASM

  belongs_to :task
  belongs_to :decision
  has_one :paper, through: :task
  belongs_to :invitee, class_name: "User", inverse_of: :invitations
  belongs_to :actor, class_name: "User"
  after_destroy :invitation_rescinded
  before_create :assign_to_latest_decision

  aasm column: :state do
    state :pending, initial: true
    state :invited do
      validates :invitee, presence: true
    end
    state :accepted
    state :rejected

    # We add guards for each state transition, as a way for tasks to optionally
    # block a certain transition if desired.

    event(:invite, {
      after: [:generate_code, :associate_existing_user],
      after_commit: :notify_invitation_invited
    }) do
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

  private

  def assign_to_latest_decision
    self.decision = paper.decisions.latest
  end

  def invitation_rescinded
    task.invitation_rescinded(paper_id: paper.id, invitee_id: invitee.id)
  end

  def notify_invitation_invited
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

  def generate_code
    self.code ||= SecureRandom.hex(10)
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
end
