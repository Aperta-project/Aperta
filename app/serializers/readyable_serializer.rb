# A base serializer for readyable models which runs ready state validations
# before serialization and serializes non persisted ready state to objects
# based on the result of the validations
class ReadyableSerializer < ActiveModel::Serializer

  def initialize(object, options)
    super(object, options)
    # run validation within the :ready namespace
    object.valid?(:ready)
  end

attributes   :ready,
             :ready_issues
end
