class MessageTask < Task
  register_task default_title: "Task", default_role: "user"

  def authorize_update?(params, user)
    p = PaperQuery.new paper, user
    p.paper ? true : false
  end
end
