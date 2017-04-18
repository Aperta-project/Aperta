# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class RelatedArticlesTask
    def self.name
      "TahiStandardTasks::RelatedArticlesTask"
    end

    def self.title
      "Related Articles"
    end

    def self.content
      []
    end
  end
end
