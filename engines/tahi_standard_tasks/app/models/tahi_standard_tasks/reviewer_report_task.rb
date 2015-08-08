module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    def body
      if super.blank?
        {}
      else
        super
      end
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
