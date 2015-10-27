module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :is_submitted
    has_many :decisions, embed: :id, include: true

    def is_submitted
      object.submitted?
    end
  end
end
