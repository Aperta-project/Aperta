module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    before_create :assign_to_latest_decision

    def body
      # body is a json column by default which returns an Array. We don't want
      # an array, we want to store properties. So if we get a blank
      # object from the DB then return a Hash instead of the default json Array.
      # Additionally, cache the body so we can set individual properties via
      # calls like "body['foo'] = 'bar'" and have them persist when this
      # task is saved.
      @body ||= begin
        result = super
        result.blank? ? {} : result
      end
    end

    def body=(new_body)
      @body = nil
      super(new_body)
    end

    def can_change?(question)
      question.errors.add :question, "can't change question" if body.has_key?("submitted")
    end

    def incomplete!
      assign_to_latest_decision
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
      paper.decisions.find(body["decision_id"]) if body["decision_id"]
    end

    def decision=(new_decision)
      body["decision_id"] = new_decision.try(:id)
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

    private

    def assign_to_latest_decision
      self.decision = paper.decisions.latest
    end
  end
end
