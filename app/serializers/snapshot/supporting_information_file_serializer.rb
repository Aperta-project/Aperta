# Serializes supporting information files
class Snapshot::SupportingInformationFileSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    [
      snapshot_property("file", "text", model[:attachment]),
      snapshot_property("title", "text", model.title),
      snapshot_property("caption", "text", model.caption),
      snapshot_property("publishable", "boolean", model.publishable)
    ]
  end
end
