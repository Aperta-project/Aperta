# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class PaperEditorTask
    def self.name
      "PaperEditorTask"
    end

    def self.title
      "Invite Academic Editor"
    end

    def self.content
      []
    end
  end
end
