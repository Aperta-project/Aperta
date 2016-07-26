class SnapshotService
  def self.configure(&blk)
    registry.instance_eval(&blk)
  end

  def self.registry
    @registry ||= Registry.new
  end

  def initialize(paper, registry = SnapshotService.registry)
    @paper = paper
    @registry = registry
  end

  def snapshot!(*things_to_snapshot)
    snapshots = preview(*things_to_snapshot)
    snapshots.each do |snapshot|
      snapshot.major_version = @paper.major_version
      snapshot.minor_version = @paper.minor_version
      snapshot.save!
    end
  end

  def preview(*things_to_snapshot)
    things_to_snapshot.flatten.map do |thing|
      serializer_klass = @registry.serializer_for(thing)
      json = serializer_klass.new(thing).as_json
      Snapshot.new(
        source: thing,
        contents: json,
        paper: @paper,
        major_version: nil,
        minor_version: nil)
    end
  end
end
