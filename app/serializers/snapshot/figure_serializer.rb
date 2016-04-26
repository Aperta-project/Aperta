# Serializes Figures
class Snapshot::FigureSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    [
      snapshot_property("file", "text", model.filename),
      snapshot_property("file_hash", "text", model.file_hash),
      snapshot_property("title", "text", model.title),
      snapshot_property("striking_image", "boolean", model.striking_image)
    ]
  end
end
