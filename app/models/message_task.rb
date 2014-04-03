class MessageTask < Task
  title 'Message'
  role 'user'

  PERMITTED_ATTRIBUTES = [:body, {participants: []}]

  has_many :comments, inverse_of: :message_task, foreign_key: 'task_id'
  has_many :message_participants, inverse_of: :message_task, foreign_key: 'task_id'
  has_many :participants, through: :message_participants

  validates :participants, length: {minimum: 1}
end
