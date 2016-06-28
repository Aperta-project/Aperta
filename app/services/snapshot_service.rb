class SnapshotService
  def self.configure(&blk)
    registry.instance_eval(&blk)
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.snapshot_paper!(paper, registry = SnapshotService.regisry)
    snapshot_service = new(paper, registry)
    snapshot_service.snapshot!(paper.snapshottable_tasks)
  end

  def initialize(paper, registry = SnapshotService.registry)
    @paper = paper
    @registry = registry
  end

  def snapshot!(*things_to_snapshot)
    preview(*things_to_snapshot).each(&:save!)
  end

  def preview(*things_to_snapshot)
    things_to_snapshot.flatten.map do |thing|
      serializer_klass = @registry.serializer_for(thing)
      json = serializer_klass.new(thing).as_json
      Snapshot.new(
        source: thing,
        contents: json,
        paper: @paper,
        major_version: @paper.major_version,
        minor_version: @paper.minor_version)
    end
  end
end
