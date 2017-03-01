# This creates the json representation of individual authors for use in
# versioning and diffing. Triggered on the paper submitted event.
class Snapshot::AuthorTaskSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    registry = SnapshotService.registry
    model.paper.all_authors
         .map { |author| registry.serializer_for(author).new(author) }
         .map(&:as_json)
  end
end
