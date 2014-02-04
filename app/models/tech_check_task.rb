class TechCheckTask < Task
  title 'Tech Check'
  role 'admin'

  def assignees
    User.admins
  end
end
