# Paper::Submitted::SnapshotPaper is an event handler that kicks off
# snapshotting a paper at a point in the time – when a paper is submitted.
#
class Paper::Submitted::SnapshotPaper

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    SnapshotService.snapshot_paper!(paper)
  end

end
