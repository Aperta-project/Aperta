class Snapshot::AuthorSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    [
      snapshot_property("first_name", "text", model.first_name),
      snapshot_property("last_name", "text", model.last_name),
      snapshot_property("middle_initial", "text", model.middle_initial),
      snapshot_property("position", "integer", model.position),
      snapshot_property("email", "text", model.email),
      snapshot_property("department", "text", model.department),
      snapshot_property("title", "text", model.title),
      snapshot_property("affiliation", "text", model.affiliation),
      snapshot_property("secondary_affiliation", "text", model.secondary_affiliation),
      snapshot_property("ringgold_id", "text", model.ringgold_id),
      snapshot_property("secondary_ringgold_id", "text", model.secondary_ringgold_id)
    ]
  end

end
