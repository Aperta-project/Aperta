# A base serializer for readyable models which runs ready state validations
# before serialization and serializes non persisted ready state to objects
# based on the result of the validations
module ReadySerializable
  extend ActiveSupport::Concern

  included do
    def initialize(object, options)
      super(object, options)
      # run validation within the :ready namespace
      object.ready?
    end

    attributes  :ready,
                :ready_issues
  end
end
