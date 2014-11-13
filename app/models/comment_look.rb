class CommentLook < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :user, inverse_of: :comment_looks
  belongs_to :comment, inverse_of: :comment_looks
  has_one :task, through: :comment
  has_one :phase, through: :task
  has_one :paper, through: :phase
end
