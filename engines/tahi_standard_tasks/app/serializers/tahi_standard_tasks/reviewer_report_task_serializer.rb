module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :decision_id, :is_submitted

    def decision_id
      object.decision.id
    end

    def is_submitted
      object.submitted?
    end
  end
end
