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
      "TahiStandardTasks::FrontMatterReviewerReport"
    end

    def self.title
      "Front Matter Reviewer Report"
    end

    def self.content
      []
    end
  end
end
