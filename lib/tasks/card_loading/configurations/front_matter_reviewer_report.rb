# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
# Currently, there is not an ActiveRecord model for FrontMatterReviewerReport
# (like there is for ReviewerReport).  This is preparatory card config work
# so that at a later point, the "questions" (CardContent) on the
# FrontMatterReviewerReportTask have a place to go.
#
module CardConfiguration
  class FrontMatterReviewerReport
    def self.name
      "FrontMatterReviewerReport"
    end

    def self.title
      "Front Matter Reviewer Report"
    end

    def self.content
      [
        {
          ident: 'front_matter_reviewer_report--decision_term',
          value_type: 'text',
          text: 'Please provide your publication recommendation:'
        },

        {
          ident: "front_matter_reviewer_report--competing_interests",
          value_type: "text",
          text: "Do you have any potential or perceived competing interests that may influence your review?"
        },

        {
          ident: "front_matter_reviewer_report--suitable",
          value_type: "boolean",
          text: "Please add your review comments in the box below.",
          children: [
            {
              ident: "front_matter_reviewer_report--suitable--comment",
              value_type: "html",
              text: "Suitable Comment"
            }
          ]
        },

        {
          ident: "front_matter_reviewer_report--includes_unpublished_data",
          value_type: "boolean",
          text: "(Optional) If previously unpublished data are included to support the conclusions, please note in the box below whether:",
          children: [
            {
              ident: "front_matter_reviewer_report--includes_unpublished_data--explanation",
              value_type: "text",
              text: "Includes Published Data Explanation"
            }
          ]
        },

        {
          ident: "front_matter_reviewer_report--additional_comments",
          value_type: "text",
          text: "(Optional) Please offer any additional confidential comments to the editor."
        },

        {
          ident: "front_matter_reviewer_report--identity",
          value_type: "text",
          text: "(Optional) If you’d like your identity to be revealed to the authors, please include your name here."
        },

        {
          ident: "front_matter_reviewer_report--attachments",
          value_type: "html",
          text: "(Optional) If you'd like to include files to support your review, please attach them here.<p>Please do NOT attach your review comments here as a separate file.<br>Instead, paste your review into the text fields provided above. Attachments should only be for supporting documents."
        }

      ]
    end
  end
end
