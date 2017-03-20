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
    # This card configuration is a sampler of vairous kinds of content
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
          }
        ]
      end
    end
  end
end
