# Serializes Figures
class Snapshot::FigureSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    [
      snapshot_property("file", "text", model[:attachment]),
      snapshot_property("title", "text", model.title),
      snapshot_property("striking_image", "boolean", model.striking_image)
    ]
  end
end
