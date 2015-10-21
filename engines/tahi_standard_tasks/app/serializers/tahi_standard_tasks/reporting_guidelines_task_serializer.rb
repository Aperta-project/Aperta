module TahiStandardTasks
  class ReportingGuidelinesTaskSerializer < ::TaskSerializer
    has_many :nested_questions, embed: :ids, include: true
  end
end
