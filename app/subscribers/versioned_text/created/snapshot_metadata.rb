class VersionedText::Created::SnapshotMetadata

  def self.call(_event_name, event_data)
    versioned_text = event_data[:record]
    paper = versioned_text.paper
    snapshot_service = SnapshotService.new(paper, paper.tasks.metadata)
    snapshot_service.snapshot!
  end

end
