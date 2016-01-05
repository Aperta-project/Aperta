class Notification < ActiveRecord::Base
  STATES = %w(read unread)

  belongs_to :paper, inverse_of: :notifications
  belongs_to :user, inverse_of: :notifications
  belongs_to :target, polymorphic: true

  validates :paper_id, :user_id, :target_id, presence: true
  validates :state, inclusion: STATES

  after_initialize :set_defaults

  def self.unread
    where(state: :unread)
  end

  private

  def set_defaults
    self.state ||= "unread"
  end
end
