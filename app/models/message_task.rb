class MessageTask < Task
  role 'user'

  def authorize_update?(params, user)
    p = PaperQuery.new paper, user
    p.paper ? true : false
  end
end
