# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ReviseTask
    def self.name
      "TahiStandardTasks::ReviseTask"
    end

    def self.title
      "Response to Reviewers"
    end

    def self.content
      []
    end
  end
end
