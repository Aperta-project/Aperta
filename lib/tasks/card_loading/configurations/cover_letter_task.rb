# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class CoverLetterTask
    def self.name
      "TahiStandardTasks::CoverLetterTask"
    end

    def self.title
      "Cover Letter Task"
    end

    def self.content
      [
        {
          ident: "cover_letter--text",
          value_type: "text",
        },
        {
          ident: "cover_letter--attachment",
          value_type: "attachment",
        }
      ]
    end
  end
end
