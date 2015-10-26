class SnapshotService::Registry
  class Error < ::StandardError; end
  class DuplicateRegistrationError < Error; end
  class NoSerializerRegisteredError < Error; end

  def initialize
    @registrations = {}
  end

  def clear
    @registrations.clear
  end

  def serialize(klass, with:)
    existing_registration = @registrations[klass.name]
    if existing_registration
      raise DuplicateRegistrationError, "#{klass.name} is already registered to be serialized by #{existing_registration}"
    end
    @registrations[klass.name] = with.name
  end

  def serializer_for(object)
    registered_serializer_klass_string = nil

    object.class.ancestors.each do |ancestor|
      registered_serializer_klass_string = @registrations[ancestor.name]
      break if registered_serializer_klass_string
    end

    unless registered_serializer_klass_string
      raise NoSerializerRegisteredError, <<-ERROR.strip_heredoc
        No serializer found for #{object.inspect} or any of its ancestors!
        Please check your serializer registrations.
      ERROR
    end

    registered_serializer_klass_string.constantize
  end
end
