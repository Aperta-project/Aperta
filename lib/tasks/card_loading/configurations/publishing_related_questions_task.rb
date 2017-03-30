# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class PublishingRelatedQuestionsTask
    def self.name
      "TahiStandardTasks::PublishingRelatedQuestionsTask"
    end

    def self.title
      "Publishing Related Questions Task"
    end

    def self.content
      [
        {
          ident: "publishing_related_questions--published_elsewhere",
          value_type: "boolean",
          text: "Have the results, data, or figures in this manuscript been published elsewhere? Are they under consideration for publication elsewhere?",
          children: [
            {
              ident: "publishing_related_questions--published_elsewhere--taken_from_manuscripts",
              value_type: "text",
              text: "Please identify which results, data, or figures have been taken from other published or pending manuscripts and explain why inclusion in this submission does not constitute dual publication."
            },
            {
              ident: "publishing_related_questions--published_elsewhere--upload_related_work",
              value_type: "attachment",
              text: "Please also upload a copy of the related work with your submission as a 'Related Manuscript' item. Note that reviewers may be asked to comment on the overlap between the related submissions."
            }
          ]
        },

        {
          ident: "publishing_related_questions--submitted_in_conjunction",
          value_type: "boolean",
          text: "Is this manuscript being submitted in conjunction with another submission?",
          children: [
            {
              ident: "publishing_related_questions--submitted_in_conjunction--corresponding_title",
              value_type: "text",
              text: "Title"
            },
            {
              ident: "publishing_related_questions--submitted_in_conjunction--corresponding_author",
              value_type: "text",
              text: "Corresponding author"
            },
            {
              ident: 'publishing_related_questions--submitted_in_conjunction--corresponding_journal',
              value_type: 'text',
              text: 'Corresponding journal'
            },
            {
              ident: 'publishing_related_questions--submitted_in_conjunction--handled_together',
              value_type: 'boolean',
              text: "This submission and the manuscript I'm submitting should be handled together"
            }
          ]
        },

        {
          ident: "publishing_related_questions--previous_interactions_with_this_manuscript",
          value_type: "boolean",
          text: "I have had previous interactions about this manuscript with a staff editor or Academic Editor of this journal.",
          children: [
            {
              ident: "publishing_related_questions--previous_interactions_with_this_manuscript--submission_details",
              value_type: "text",
              text: "Please enter manuscript number and editor name, if known"
            }
          ]
        },

        {
          ident: "publishing_related_questions--presubmission_inquiry",
          value_type: "boolean",
          text: "I submitted a presubmission inquiry for this manuscript.",
          children: [
            {
              ident: "publishing_related_questions--presubmission_inquiry--submission_details",
              value_type: "text",
              text: "Please enter manuscript number and editor name, if known"
            }
          ]
        },

        {
          ident: "publishing_related_questions--other_journal_submission",
          value_type: "boolean",
          text: "This manuscript was previously submitted to a different PLOS journal as either a presubmission inquiry or a full submission.",
          children: [
            {
              ident: "publishing_related_questions--other_journal_submission--submission_details",
              value_type: "text",
              text: "Please enter manuscript number and editor name, if known"
            }
          ]
        },

        {
          ident: "publishing_related_questions--author_was_previous_journal_editor",
          value_type: "boolean",
          text: "One or more of the authors (including myself) currently serve, or have previously served, as an Academic Editor or Guest Editor for this journal."
        },

        {
          ident: "publishing_related_questions--intended_collection",
          value_type: "text",
          text: "If your submission is intended for a <a target='_blank' href='http://collections.plos.org/'>PLOS Collection</a>, enter the name of the collection in the box below. Please also ensure the name of the collection is included in your cover letter."
        },

        {
          ident: "publishing_related_questions--short_title",
          value_type: "text",
          text: "Please give your paper a short title. Short titles are used as the running header on published PDFs."
        }
      ]
    end
  end
end
