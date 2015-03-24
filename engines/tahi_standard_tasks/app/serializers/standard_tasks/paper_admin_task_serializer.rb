module StandardTasks
  class PaperAdminTaskSerializer < TaskSerializer
    embed :ids
    has_one :admin, include: true, root: :users

    def admin
      object.paper.admin
    end
  end
end
