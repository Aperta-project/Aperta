class CommentLook < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :comment, inverse_of: :comment_looks
  belongs_to :user, inverse_of: :comment_looks
  has_one :paper, through: :task
  has_one :task, through: :comment

  validates :comment, :user, presence: true
end
