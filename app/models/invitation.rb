class Invitation < ActiveRecord::Base
  include AASM

  belongs_to :task, inverse_of: :invitations
  has_one :paper, through: :task
  belongs_to :invitee, class_name: "User", inverse_of: :invitations
  belongs_to :actor, class_name: "User", inverse_of: :invitations

  after_commit :notify_invitation_invited, on: :create

  aasm column: :state do
    state(:invited, {
      initial: true,
      before_enter: [:generate_code, :associate_existing_user]
    })
    state :accepted
    state :rejected

    event(:accept, {
      after: :associate_existing_user,
      after_commit: :notify_invitation_accepted
    }) do
      transitions from: :invited, to: :accepted
    end
    event :reject do
      transitions from: :invited, to: :rejected
    end
  end

  private

  def generate_code
    self.code ||= SecureRandom.hex(10)
  end

  def notify_invitation_invited
    task.invitation_invited(self)
  end

  def notify_invitation_accepted
    task.invitation_accepted(self)
  end

  def associate_existing_user
    self.invitee ||= User.find_by(email: email)
  end
end
