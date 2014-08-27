class MessageTask < Task
  role 'user'

  validates :participants, length: {minimum: 1}

  def authorize_update?(params, user)
    p = PaperQuery.new paper, user
    p.paper ? true : false
  end
end
