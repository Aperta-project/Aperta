class Snapshot::FunderSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    [
      snapshot_property("name", "text", model.name),
      snapshot_property("grant_number", "text", model.grant_number),
      snapshot_property("website", "text", model.website)
    ]
  end
end
