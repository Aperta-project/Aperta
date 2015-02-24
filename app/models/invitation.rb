class Invitation < ActiveRecord::Base
  include AASM

  belongs_to :task, inverse_of: :invitations
  has_one :paper, through: :task
  belongs_to :invitee, class_name: "User", inverse_of: :invitations
  belongs_to :actor, class_name: "User", inverse_of: :invitations

  aasm column: :state do
    state :pending, initial: true, before_enter: [:generate_code, :associate_existing_user]
    state :accepted
    state :rejected

    event :accept, after: :associate_existing_user, after_commit: :notify_task do
      transitions from: :pending, to: :accepted
    end
    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  private

  def generate_code
    self.code ||= SecureRandom.hex(10)
  end

  def notify_task
    task.invitation_accepted(self)
  end

  def associate_existing_user
    self.invitee ||= User.find_by(email: email)
  end
end
