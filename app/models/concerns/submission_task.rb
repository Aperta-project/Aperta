module SubmissionTask
  extend ActiveSupport::Concern

  included do
    Task.submission_types ||= []
    unless Task.submission_types.include?(name)
      Task.submission_types << name
    end
  end
end
