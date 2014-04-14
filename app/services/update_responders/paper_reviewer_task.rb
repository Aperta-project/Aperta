module UpdateResponders
  class PaperReviewerTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      phases = @task.paper.phases.where(name: 'Get Reviews')
      ActiveModel::ArraySerializer.new(phases, root: :phases)
    end
  end
end
