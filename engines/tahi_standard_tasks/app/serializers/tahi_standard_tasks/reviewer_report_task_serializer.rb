module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :decision_id, :is_submitted

    def decision_id
      object.decision.id if object.decision
    end

    def is_submitted
      object.submitted?
    end
  end
end
