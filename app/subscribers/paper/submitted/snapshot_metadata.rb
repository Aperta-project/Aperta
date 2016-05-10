class Paper::Submitted::SnapshotMetadata

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    snapshot_service = SnapshotService.new(paper)
    snapshot_service.snapshot!(paper.tasks.snapshot_tasks)
  end

end
