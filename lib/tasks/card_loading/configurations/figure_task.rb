# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class FigureTask
    def self.name
      "TahiStandardTasks::FigureTask"
    end

    def self.title
      "Figures Task"
    end

    def self.content
      [
        {
          ident: "figures--complies",
          value_type: "boolean",
          text: "Yes - I confirm our figures comply with the guidelines."
        }
      ]
    end
  end
end
