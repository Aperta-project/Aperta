# This module contains cards that should not be auto-loaded in most
# environments.
# To load it, run
#
#     rake "cards:load_one[Card Configuration Sampler, 1]"
#
# Where 1 is the id of the journal you'd like to add it to.
#
module CardConfiguration
  module NonstandardConfigurations
    # This card configuration is a sampler of various kinds of content
    # that a custom-made card can have.
    class CardConfigurationSamplerTask
      def self.name
        "Card Configuration Sampler"
      end

      def self.title
        "Card Configuration Sampler"
      end

      def self.content
        [
          {
            ident: "card_configuration_sampler--text",
            value_type: nil,
            content_type: "text",
            text: "This is a block of instructional text. It is not a question, and requires no answer."
          },
          {
            text: "This is the text of a custom question.  Agree?",
            value_type: 'text',
            content_type: "short-input",
          },
          {
            text: "This is a second question",
            value_type: "text",
            content_type: "short-input"
          },
          {
            ident: "submision-date",
            text: "A Title",
            value_type: "text",
            content_type: "date-picker"
          },
          {
            text: "This is a check box",
            label: "Check this box if you agree",
            value_type: "boolean",
            content_type: "check-box"
          },
          {
            label: "Check this box if you disagree instead",
            value_type: "boolean",
            content_type: "check-box"
          },
          {
            text: "This is a radio button question.  <b>Please</b> pick a choice",
            value_type: 'text',
            content_type: "radio",
            possible_values: [{ "label" => "Choice 1", "value" => 1 }, { "label" => "Choice 2", "value" => 2 }],
            children: [
              {
                value_type: nil,
                content_type: "display-with-value",
                visible_with_parent_answer: "1",
                children: [
                  {
                    value_type: nil,
                    content_type: "field-set",
                    children: [
                      {
                        value_type: nil,
                        content_type: "text",
                        text: "You have answered 1 to the radio question"
                      },
                      {
                        text: "What'd you think of that first question, huh?",
                        value_type: 'text',
                        content_type: "short-input",
                      }
                    ]
                  }
                ]
              },
              {
                value_type: nil,
                content_type: "display-with-value",
                visible_with_parent_answer: "2",
                children: [
                  {
                    value_type: nil,
                    content_type: "field-set",
                    children: [
                      {
                        value_type: nil,
                        content_type: "text",
                        text: "This is a message that comes up when you pick Choice 2 up above"
                      },
                      {
                        text: "Now that you've picked that second choice, what will you do next?",
                        value_type: 'text',
                        content_type: "short-input",
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            text: "Type a paragraph",
            value_type: "text",
            content_type: "paragraph-input"
          },
          {
            text: "This is a dropdown question.  <b>Please</b> pick a choice",
            value_type: 'text',
            content_type: "dropdown",
            possible_values: [{ "label" => "Choice 1", "value" => 1 }, { "label" => "Choice 2", "value" => 2 }]
          },
          {
            text: "Eat a hot dog; take a picture; upload it here",
            value_type: "attachment",
            content_type: "file-uploader",
            possible_values: [{ "label" => "tif", "value" => ".tif" }, { "label" => "png", "value" => ".png" }],
            label: "Ima Button"
          }
        ]
      end
    end
  end
end
