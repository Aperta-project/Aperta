# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ReviewerReport
    def self.name
      "ReviewerReport"
    end

    def self.title
      "Reviewer Report"
    end

    def self.content
      [
        {
          ident: 'reviewer_report--decision_term',
          value_type: 'text',
          text: 'Please provide your publication recommendation:'
        },

        {
          ident: "reviewer_report--competing_interests",
          value_type: "boolean",
          text: "Do you have any potential or perceived competing interests that may influence your review?",
          children: [
            {
              ident: "reviewer_report--competing_interests--detail",
              value_type: "text",
              text: "Comment"
            }
          ]
        },

        {
          ident: "reviewer_report--identity",
          value_type: "text",
          text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here."
        },

        {
          ident: "reviewer_report--comments_for_author",
          value_type: "html",
          text: "Add your comments to authors below."
        },

        {
          ident: "reviewer_report--additional_comments",
          value_type: "text",
          text: "(Optional) If you have any additional confidential comments to the editor, please add them below."
        },

        {
          ident: "reviewer_report--suitable_for_another_journal",
          value_type: "boolean",
          text: "If the manuscript does not meet the standards of <em>PLOS Biology</em>, do you think it is suitable for another <a href='https://www.plos.org/publications'><em>PLOS</em> journal</a>?",
          children: [
            {
              ident: "reviewer_report--suitable_for_another_journal--journal",
              value_type: "text",
              text: "Other Journal"
            }
          ]
        }
      ]
    end
  end
end
