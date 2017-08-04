module CardConfiguration
  module NonstandardConfigurations
    # This class defines the specific attributes of a particular Card and it can be
    # used to create a new valid Card into the system.  The `content` can be used
    # to create CardContent for the Card.
    #
    # This particular class is only used by rspec test factories.
    #
    class MetadataTestTask
      def self.name
        "MetadataTestTask"
      end

      def self.title
        "Metadata Test Task"
      end

      def self.content
        []
      end
    end
  end
end
