module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    def body
      super.blank? ? {} : super
    end

    def can_change?(question)
      question.errors.add :question, "can't change question" if body.has_key?("submitted")
    end

    def incomplete!
      update!(
        completed: false,
        body: body.except("submitted")
      )
    end

    # +decision+ returns the _relevant_ decision to this task. This is so
    # the appropriate questions and responses for this task can be determined.
    #
    # This is impacted by the concept of "latest decision" in the app as it's
    # not always the latest rendered decision by an Academic Editor.
    def decision
      if !paper.submitted? && submitted?
        paper.decisions[1]
      else
        paper.decisions[0]
      end
    end

    def send_emails
      return unless on_card_completion?
      paper.editors.each do |editor|
        ReviewerReportMailer.delay.notify_editor_email(task_id: id,
                                                       recipient_id: editor.id)
      end
    end

    def submitted?
      !!body["submitted"]
    end
  end
end
