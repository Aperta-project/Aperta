# Snapshot::AttachmentSerializer is responsible for generically
# snapshotting Attachment models.
#
# Since multiple kinds of attachments re-use the Attachment model as a
# base-class this serializer will snapshot all of the properties, even if they
# are unused.
#
# It is the responsibility of the whomever is consuming these attachment snapshots to use or not use
# the values captured.
#
class Snapshot::AttachmentSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    properties = [
      snapshot_property('caption', 'text', model.caption),
      snapshot_property('category', 'text', model.category),
      snapshot_property('file', 'text', model.filename),
      snapshot_property('file_hash', 'text', model.file_hash),
      snapshot_property('label', 'text', model.label),
      snapshot_property('publishable', 'boolean', model.publishable),
      snapshot_property('status', 'text', model.status),
      snapshot_property('title',  'text', model.title),
      snapshot_property('url', 'url', model.non_expiring_proxy_url)
    ]
    if model.respond_to?(:striking_image)
      properties << snapshot_property('striking_image', 'boolean', model.striking_image)
    end
    properties
  end
end
