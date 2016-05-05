class Paper::Submitted::SnapshotMetadata

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    snapshot_service = SnapshotService.new(paper)
    snapshot_service.snapshot!(tasks_to_snapshot(paper.snapshot_tasks))
  end

end
