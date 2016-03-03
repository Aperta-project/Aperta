module SubmissionTask
  extend ActiveSupport::Concern

  def allow_update?
    paper.editable?
  end

  def submission_task?
    true
  end

  def activity_feed_name
    'manuscript'
  end
end
