# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class TitleAndAbstractTask
    def self.name
      "TahiStandardTasks::TitleAndAbstractTask"
    end

    def self.title
      "Title And Abstract"
    end

    def self.content
      []
    end
  end
end
