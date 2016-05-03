module SubmissionTask
  extend ActiveSupport::Concern

  included do
    Task.submission_types ||= Set.new
    Task.submission_types.add name
  end
end
