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
            placeholder: "Your text here"
          },
          {
            text: "This is a second question",
            value_type: "text",
            content_type: "short-input"
          },
          {
            text: "This is a radio button question.  <b>Please</b> pick a choice",
            value_type: 'text',
            content_type: "radio",
            possible_values: [{ "label" => "Choice 1", "value" => 1 }, { "label" => "Choice 2", "value" => 2 }]
          },
          {
            text: "Type a paragraph",
            value_type: "text",
            content_type: "paragraph-input"
          }
        ]
      end
    end
  end
end
