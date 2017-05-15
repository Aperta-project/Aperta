# ErrorSerializer is intended to be used for allowing controllers to not
# only respond with an HTTP error status code, but to include a useful
# body which contains information about the error.
class ErrorSerializer < ActiveModel::Serializer
  # Provide a model for our error, but hide its details at this time since
  # it's not used anywhere outside of this serializer.
  #
  # https://github.com/rails-api/active_model_serializers/blob/master/docs/howto/serialize_poro.md
  class Error
    alias :read_attribute_for_serialization :send

    attr_accessor :message

    def initialize(message:)
      @message = message
    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self)
    end
  end

  attributes :message

  # attributes is expected to contain attributes that the Error model
  # above defines, e.g. :message
  def initialize(attributes, *args)
    model = Error.new(attributes)
    super(model, *args)
  end
end
