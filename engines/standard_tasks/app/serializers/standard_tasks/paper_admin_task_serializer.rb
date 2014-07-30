module StandardTasks
  class PaperAdminTaskSerializer < TaskSerializer
    embed :ids

    has_one :admin, include: true, root: :users
    has_many :admins, include: true, root: :users

    def admin
      object.paper.admins.first
    end

    def admins
      assignees
    end
  end
end
