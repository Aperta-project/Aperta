# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class RegisterDecisionTask
    def self.name
      "TahiStandardTasks::RegisterDecisionTask"
    end

    def self.title
      "Register Decision Task"
    end

    def self.content
      [
        {
          ident: "register_decision_questions--selected-template",
          value_type: "text",
          text: "Please select a template."
        },

        {
          ident: "register_decision_questions--to-field",
          value_type: "text",
          text: "Enter the email here"
        },

        {
          ident: "register_decision_questions--subject-field",
          value_type: "text",
          text: "Enter the subject here"
        }
      ]
    end
  end
end
