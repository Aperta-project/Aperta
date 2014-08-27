class MessageTask < Task
  role 'user'

  has_many :message_participants, inverse_of: :message_task, foreign_key: 'task_id', dependent: :destroy
  has_many :participants, through: :message_participants

  validates :participants, length: {minimum: 1}

  def permitted_attributes
    super + [{participant_ids: []}]
  end

  def authorize_update?(params, user)
    p = PaperQuery.new paper, user
    p.paper ? true : false
  end
end
