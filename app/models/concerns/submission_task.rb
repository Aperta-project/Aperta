module SubmissionTask
  extend ActiveSupport::Concern

  def allow_update?
    paper.editable?
  end

  def submission_task?
    true
  end
end
