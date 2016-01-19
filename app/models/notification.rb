class Notification < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper, inverse_of: :notifications
  belongs_to :user, inverse_of: :notifications
  belongs_to :target, polymorphic: true

  validates :paper_id, :user_id, :target_id, presence: true
end
