# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ReviewerRecommendation
    def self.name
      "TahiStandardTasks::ReviewerRecommendation"
    end

    def self.title
      "Reviewer Recommendation"
    end

    def self.content
      [
        {
          ident: "reviewer_recommendations--recommend_or_oppose",
          value_type: "boolean",
          text: "Are you recommending or opposing this reviewer?"
        },
        {
          ident: "reviewer_recommendations--reason",
          value_type: "text",
          text: "Optional: reason for recommending or opposing this reviewer"
        }
      ]
    end
  end
end
