class Invitation < ActiveRecord::Base
  include EventStreamNotifier
  include AASM

  belongs_to :task, inverse_of: :invitations
  has_one :paper, through: :task
  belongs_to :invitee, class_name: "User", inverse_of: :invitations
  belongs_to :actor, class_name: "User", inverse_of: :invitations

  aasm column: :state, :whiny_transitions => false do
    state :pending, initial: true
    state :invited do
      validates :invitee, presence: true
    end
    state :accepted
    state :rejected
    state :willing
    state :closed

    event(:invite, {
      after: [:generate_code, :associate_existing_user],
      after_commit: :notify_invitation_invited
    }) do
      transitions from: :pending, to: :invited
    end
    event(:accept, {
      after_commit: :notify_invitation_accepted
    }) do
      transitions from: :invited, to: :accepted, guard: :accept_allowed?
      transitions from: :closed, to: :willing
    end
    event :reject do
      transitions from: [:invited, :closed], to: :rejected
    end
    event :close do
      transitions from: :invited, to: :closed
    end
  end

  private

  def notify_invitation_invited
    task.invitation_invited(self) if task.respond_to?(:invitation_invited)
  end

  def notify_invitation_accepted
    task.invitation_accepted(self) if task.respond_to?(:invitation_accepted)
  end

  def accept_allowed?
     task.respond_to?(:accept_allowed?) ? task.accept_allowed?(self) : true
  end

  def associate_existing_user
    update(invitee: User.find_by(email: email))
  end

  def generate_code
    self.code ||= SecureRandom.hex(10)
  end
end
