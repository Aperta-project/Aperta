class SnapshotService
  def self.configure(&blk)
    registry.instance_eval(&blk)
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.snapshot_paper!(paper, registry = SnapshotService.registry)
    snapshot_service = new(paper, registry)

    things_to_snapshot = []
      .concat(paper.snapshottable_tasks)
      .concat(paper.figures)
      .concat(paper.supporting_information_files)
      .concat(paper.adhoc_attachments)
      .concat(paper.question_attachments)

    snapshot_service.snapshot!(things_to_snapshot)
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
