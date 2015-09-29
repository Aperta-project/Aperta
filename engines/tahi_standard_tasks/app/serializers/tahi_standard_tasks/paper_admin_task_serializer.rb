module TahiStandardTasks
  class PaperAdminTaskSerializer < TaskSerializer
    embed :ids
    has_one :admin

    def admin
      object.paper.admin
    end
  end
end
