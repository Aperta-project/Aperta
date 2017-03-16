# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class EarlyPostingTask
    def self.name
      "TahiStandardTasks::EarlyPostingTask"
    end

    def self.title
      "Early Posting Task"
    end

    def self.content
      [
        {
          ident: "early-posting--consent",
          value_type: "boolean",
          text: "Yes, I agree to publish an early version of my article"
        }
      ]
    end
  end
end
