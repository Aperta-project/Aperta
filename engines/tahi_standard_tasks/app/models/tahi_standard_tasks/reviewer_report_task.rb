module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    before_create :assign_to_latest_decision
    has_many :decisions, -> { uniq }, through: :nested_question_answers

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "competing_interests",
        value_type: "text",
        text: "Do you have any potential or perceived competing interests that may influence your review?",
        position: 1
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "support_conclusions",
        value_type: "boolean",
        text: "Is the manuscript technically sound, and do the data support the conclusions?",
        position: 2,
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Explanation",
            position: 1
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "statistical_analysis",
        value_type: "boolean",
        text: "Has the statistical analysis been performed appropriately and rigorously?",
        position: 3,
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Statistical Analysis Explanation",
            position: 1
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "standards",
        value_type: "boolean",
        text: "Does the manuscript adhere to standards in this field for data availability?",
        position: 4,
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Standards Explanation",
            position: 1
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "additional_comments",
        value_type: "text",
        text: "(Optional) Please offer any additional comments to the author.",
        position: 5
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "identity",
        value_type: "text",
        text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
        position: 6
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    # find_or_build_answer_for(...) will return the associated answer for this
    # task given :nested_question. For ReviewerReportTask this enforces the
    # lookup to be scoped to this task's current decision. Answers associated
    # with previous decisions will not be returned.
    #
    # == Optional Parameters
    #  * decision - ignored if provided, always enforces the task's decision.id
    #
    def find_or_build_answer_for(nested_question:, **_kwargs)
      super(
        nested_question: nested_question,
        decision: decision
      )
    end

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

    def can_change?(_)
      !submitted?
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
      previous_decision_ids = body["previous_decision_ids"] || []
      current_decision_id = body["decision_id"]

      if current_decision_id
        previous_decision_ids.push current_decision_id
      end

      update_body(
        "decision_id" => new_decision.try(:id),
        "previous_decision_ids" => previous_decision_ids
      )
    end

    def previous_decision_ids
      if body["previous_decision_ids"]
        body["previous_decision_ids"]
      else
        []
      end
    end

    def previous_decisions
      paper.decisions.where(id: previous_decision_ids)
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

    def update_body(hsh)
      self.body = body.merge(hsh)
    end
  end
end
