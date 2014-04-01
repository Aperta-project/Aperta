class PaperAdminTaskSerializer < TaskSerializer
   embed :ids

   has_one :admin, include: true, root: :users
   has_many :admins, include: true, root: :users

  def admin
    assignee
  end

  def admins
    assignees
  end
end
