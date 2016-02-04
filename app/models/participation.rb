# Participation represents the old way of doing things. It is deprecated
# and will be removed in the near future.
class Participation < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :task
  belongs_to :user, inverse_of: :participations
  has_one :paper, through: :task

  validates :user, presence: true

  after_create :add_paper_role
  after_destroy :remove_paper_role

  private

  def add_paper_role
    paper.paper_roles.participants.where(user: user).first_or_create
  end

  def remove_paper_role
    return if user.blank? || paper.participants.include?(user)
    paper.paper_roles.participants.where(
      paper_roles: { user_id: user.id }
    ).destroy_all
  end
end
