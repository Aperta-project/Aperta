module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :is_submitted
    has_many :decisions, embed: :id, include: false
    has_many :reviewer_reports, embed: :id, include: false

    def is_submitted
      object.submitted?
    end

    def decisions
      object.paper.decisions
    end
  end
end
