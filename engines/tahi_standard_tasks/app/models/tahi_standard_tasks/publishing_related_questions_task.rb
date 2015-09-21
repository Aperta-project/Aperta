module TahiStandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    register_task default_title: "Publishing Related Questions", default_role: "author"

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "published_elsewhere",
        value_type: "boolean",
        text: "Have the results, data, or figures in this manuscript been published elsewhere? Are they under consideration for publication elsewhere?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "taken_from_manuscripts",
            value_type: "text",
            text: "Please identify which results, data, or figures have been taken from other published or pending manuscripts, and explain why inclusion in this submission does not constitute dual publication.",
            children: []
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "submitted_in_conjunction",
        value_type: "boolean",
        text: "Is this manuscript being submitted in conjunction with another submission?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "corresponding_title",
            value_type: "text",
            text: "Title",
            children: []
          ),
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "corresponding_author",
            value_type: "text",
            text: "Corresponding author",
            children: []
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "previous_interactions_with_this_manuscript",
        value_type: "boolean",
        text: "I have had previous interactions about this manuscript with a staff editor or Academic Editor of this journal.",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "submission_details",
            value_type: "text",
            text: "Please enter manuscript number and editor name, if known",
            children: []
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "presubmission_inquiry",
        value_type: "boolean",
        text: "I submitted a presubmission inquiry for this manuscript.",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "submission_details",
            value_type: "text",
            text: "Please enter manuscript number and editor name, if known",
            children: []
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "other_journal_submission",
        value_type: "boolean",
        text: "This manuscript was previously submitted to a different PLOS journal as either a presubmission inquiry or a full submission.",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "submission_details",
            value_type: "text",
            text: "Please enter manuscript number and editor name, if known",
            children: []
          )
        ]
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "author_was_previous_journal_editor",
        value_type: "boolean",
        text: "One or more of the authors (including myself) currently serve, or have previously served, as an Academic Editor or Guest Editor for this journal.",
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "intended_collection",
        value_type: "text",
        text: "If your submission is intended for a PLOS Collection, enter the name of the collection in the box below. Please also ensure the name of the collection is included in your cover letter.",
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "us_government_employees",
        value_type: "boolean",
        text: "Are you or any of the contributing authors an employee of the United States Government?",
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

  end
end
