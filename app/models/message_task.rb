class MessageTask < Task
  role 'user'

  def permitted_attributes
    super + [:body, {participant_ids: []}]
  end

  has_many :comments, inverse_of: :message_task, foreign_key: 'task_id', dependent: :destroy
  has_many :message_participants, inverse_of: :message_task, foreign_key: 'task_id', dependent: :destroy
  has_many :participants, through: :message_participants

  validates :participants, length: {minimum: 1}

  def authorize_update!(params, user)
    p = PaperPolicy.new paper, user
    p.paper ? true : false
  end
end
