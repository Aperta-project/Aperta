class Invitation < ActiveRecord::Base

  belongs_to :task, inverse_of: :invitations
  has_one :paper, through: :task
  belongs_to :invitee, class_name: "User", inverse_of: :invitations
  belongs_to :actor, class_name: "User", inverse_of: :invitations

  scope :pending, -> { where(state: "pending") }

end
