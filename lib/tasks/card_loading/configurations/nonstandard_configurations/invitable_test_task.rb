# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
# This particular class is only used by rspec test factories.
#
module CardConfiguration
  class InvitableTestTask
    def self.name
      "InvitableTestTask"
    end

    def self.title
      "Invitable Test Task"
    end

    def self.content
      []
    end
  end
end
