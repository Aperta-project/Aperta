class Snapshot::QuestionAttachmentSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    [
      snapshot_property("file", "text", model.filename),
      snapshot_property("title", "text", model.title),
      snapshot_property("caption", "text", model.caption),
      snapshot_property("status", "text", model.status)
    ]
  end
end
