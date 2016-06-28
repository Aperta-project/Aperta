class Paper::Submitted::SnapshotPaper

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    SnapshotService.snapshot_paper!(paper)
  end

end
