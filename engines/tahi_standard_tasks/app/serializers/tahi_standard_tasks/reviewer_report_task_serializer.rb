module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    attributes :is_submitted
    has_many :previous_decisions, embed: :id, include: true
    has_one :decision, embed: :id, include: true

    def is_submitted
      object.submitted?
    end
  end
end
