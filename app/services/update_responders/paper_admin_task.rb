module UpdateResponders
  class PaperAdminTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      generate_json_response(@task.tasks_for_admin, :tasks)
    end
  end
end
