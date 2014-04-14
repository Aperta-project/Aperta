module UpdateResponders
  class PaperAdminTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      ActiveModel::ArraySerializer.new(@task.tasks_for_admin, root: :tasks)
    end
  end
end
