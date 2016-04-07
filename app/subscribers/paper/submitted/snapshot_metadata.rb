class Paper::Submitted::SnapshotMetadata

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    snapshot_service = SnapshotService.new(paper)
    snapshot_service.snapshot!(tasks_to_snapshot(paper))
  end

  def self.tasks_to_snapshot(paper)
    reviewer_task = "TahiStandardTasks::ReviewerRecommendationsTask"
    paper.tasks.metadata << paper.tasks.of_type(reviewer_task)
  end

end
