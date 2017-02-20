module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :is_submitted
    has_many :decisions, embed: :id, include: true
    has_many :reviewer_reports, embed: :id, include: true

    def is_submitted
      object.submitted?
    end

    def decisions
      object.paper.decisions
    end
  end
end
