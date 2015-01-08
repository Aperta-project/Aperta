module StandardTasks
  class ReviewerReportTask < Task
    def self.permitted_attributes
      super + [{ paper_review_attributes: [:body, :id] }]
    end

    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    has_one :paper_review, foreign_key: 'task_id'

    accepts_nested_attributes_for :paper_review

    def send_emails
      return unless previous_changes["completed"] == [false, true]
      paper.editors.each do |editor|
        ReviewerReportMailer.delay.notify_editor_email(task_id: id,
                                                       recipient_id: editor.id)
      end
    end
  end
end
