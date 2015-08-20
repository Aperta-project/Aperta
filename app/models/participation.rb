class Participation < ActiveRecord::Base
  include EventStream::Notifiable
  extend HasFeedActivities

  belongs_to :task, inverse_of: :participations
  belongs_to :user, inverse_of: :participations
  has_one :paper, through: :task

  validates :user, presence: true

  after_create :add_paper_role
  after_destroy :remove_paper_role

  feed_activities subject: :paper, feed_names: ['manuscript', 'workflow'] do
    activity(:created) { "Added Contributor: #{user.full_name}" }
    activity(:destroyed) { "Removed Contributor: #{user.full_name}" }
  end

  private

  def add_paper_role
    paper.paper_roles.participants.where(user: user).first_or_create
  end

  def remove_paper_role
    if user.present? && paper.participants.where(id: user.id).none?
      paper.paper_roles.participants.where(user: user).destroy_all
    end
  end
end
