module SubmissionTask
  extend ActiveSupport::Concern

  def allow_update?
    paper.editable?
  end

  included do
    Task.submission_types ||= Set.new
    Task.submission_types.add name
  end
end
