module TahiStandardTasks
  class ReviewerReportTaskSerializer < TaskSerializer
    has_one :paper_review, embed: :id
  end
end
