# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class CompetingInterestsTask
    def self.name
      "TahiStandardTasks::CompetingInterestsTask"
    end

    def self.title
      "Competing Interests Task"
    end

    def self.content
      [
        {
          ident: "competing_interests--has_competing_interests",
          value_type: "boolean",
          text: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://journals.plos.org/plosbiology/s/competing-interests'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
          children: [
            {
              ident: "competing_interests--statement",
              value_type: "text",
              text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\""
            }
          ]
        }
      ]
    end
  end
end
