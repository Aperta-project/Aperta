# This creates the json representation of group authors for use in
# versioning and diffing. Triggered on the paper submitted event,
# via the Snapshot::AuthorTaskSerializer.
class Snapshot::GroupAuthorSerializer < Snapshot::BaseSerializer
  private

  # Disabling ABC checking because this is one method that returns a
  # list of properties; it's not conceptually complex.
  # rubocop:disable Metrics/AbcSize
  def snapshot_properties
    [
      snapshot_property(
        "contact_first_name", "text", model.contact_first_name),
      snapshot_property("contact_last_name", "text", model.contact_last_name),
      snapshot_property(
        "contact_middle_name", "text", model.contact_middle_initial),
      snapshot_property("position", "integer", model.position),
      snapshot_property("contact_email", "text", model.contact_email),
      snapshot_property("name", "text", model.name),
      snapshot_property("initial", "text", model.initial)
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
