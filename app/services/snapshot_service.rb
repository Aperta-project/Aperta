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
      existing_registration = @registrations[klass]
      if existing_registration
        raise "DuplicateRegistrationError #{klass} is already registered to be serialized by #{existing_registration}"
      end
      @registrations[klass] = with
    end

    def serializer_for(object)
      @registrations.fetch(object.class) do
        raise "NoSerializerRegistered for #{object.inspect}"
      end
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
