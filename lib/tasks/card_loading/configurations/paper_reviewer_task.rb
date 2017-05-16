# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class PaperReviewerTask
    def self.name
      "TahiStandardTasks::PaperReviewerTask"
    end

    def self.title
      "Invite Reviewers"
    end

    def self.content
      []
    end
  end
end
