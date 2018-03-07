class CommentLook < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable

  belongs_to :comment, inverse_of: :comment_looks
  belongs_to :user, inverse_of: :comment_looks
  has_one :paper, through: :task
  has_one :task, through: :comment

  validates :comment, :user, presence: true

  def user_can_view?(my_user)
    # A user can view their own comment looks
    my_user == user
  end
end
