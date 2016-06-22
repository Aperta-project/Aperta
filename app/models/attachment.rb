class Attachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :task
  has_one :paper, through: :task

  validates :task, presence: true
end
