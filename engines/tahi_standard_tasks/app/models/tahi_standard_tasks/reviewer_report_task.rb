module TahiStandardTasks
  class ReviewerReportTask < Task
    register_task default_title: 'Reviewer Report', default_role: 'reviewer'

    def self.nested_questions
      questions = []

      # questions??

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "competing_interests",
        value_type: "text",
        text: "Do you have any potential or perceived competing interests that may influence your review?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "support_conclusions",
        value_type: "boolean",
        text: "Is the manuscript technically sound, and do the data support the conclusions?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Explanation"
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "statistical_analysis",
        value_type: "boolean",
        text: "Has the statistical analysis been performed appropriately and rigorously?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Statistical Analysis Explanation"
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "standards",
        value_type: "boolean",
        text: "Does the manuscript adhere to standards in this field for data availability?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Standards Explanation"
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "intelligible",
        value_type: "boolean",
        text: "Is the manuscript presented in an intelligible fashion and written in standard English?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "explanation",
            value_type: "text",
            text: "Intelligible Explanation"
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "additional_comments",
        value_type: "text",
        text: "(Optional) Please offer any additional comments to the author."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "identity",
        value_type: "text",
        text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here."
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

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
