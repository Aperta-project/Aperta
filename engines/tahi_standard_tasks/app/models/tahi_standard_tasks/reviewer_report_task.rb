module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    def body
      super.blank? ? {} : super
    end

    def can_change?(question)
      question.errors.add :question, "can't change question" if body.has_key?("submitted")
    end

    def send_emails
      return unless on_card_completion?
      paper.editors.each do |editor|
        ReviewerReportMailer.delay.notify_editor_email(task_id: id,
                                                       recipient_id: editor.id)
      end
    end
  end
end
