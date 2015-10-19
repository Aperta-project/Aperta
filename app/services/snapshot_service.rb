class SnapshotService
  def self.configure(&blk)
    registry.instance_eval(&blk)
  end

  def self.registry
    @registry ||= Registry.new
  end

  class Registry
    def initialize
      @registrations = {}
    end

    def serialize(klass, with:)
      existing_registration = @registrations[klass.name]
      if existing_registration
        raise "DuplicateRegistrationError #{klass.name} is already registered to be serialized by #{existing_registration}"
      end
      @registrations[klass.name] = with.name
    end

    def serializer_for(object)
      serializer_klass_string = @registrations.fetch(object.class.name) do
        raise "NoSerializerRegistered for #{object.inspect}"
      end
      serializer_klass_string.constantize
    end
  end

  def initialize(paper, things_to_snapshot, registry=SnapshotService.registry)
    @paper = paper
    @things_to_snapshot = things_to_snapshot
    @registry = registry
  end

  def snapshot!
    latest_version = @paper.latest_version
    major_version = latest_version.major_version
    minor_version = latest_version.minor_version

    @things_to_snapshot.each do |thing|
      serializer_klass = @registry.serializer_for(thing)
      # TODO - rename snapshot method to as_json
      json = serializer_klass.new(thing).snapshot
      Snapshot.create!(
        contents: json,
        major_version: major_version,
        minor_version: minor_version,
        paper: @paper,
        source: thing
      )
    end
  end
end
