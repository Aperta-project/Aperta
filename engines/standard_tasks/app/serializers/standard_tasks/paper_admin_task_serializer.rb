module StandardTasks
  class PaperAdminTaskSerializer < TaskSerializer
    embed :ids
    has_one :admin, include: true, root: :users
    has_many :possible_admins, include: true, root: :users

    def admin
      object.paper.admin
    end

    def possible_admins
      object.paper.possible_admins
    end
  end
end
