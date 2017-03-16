# This module contains cards that should not be auto-loaded in most
# environments
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
