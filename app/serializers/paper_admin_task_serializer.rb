class PaperAdminTaskSerializer < TaskSerializer
   attributes :admins, :admin

  def admin
    assignee
  end

  def admins
    assignees
  end
end
