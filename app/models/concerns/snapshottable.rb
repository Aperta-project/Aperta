# Snapshottable can be included in a model to indicate that it is a
# a snapshottable resource and may have associated snapshots of itself.
#
# A class and all of its instances can be marked as
# snapshottable by setting <tt>self.snapshottable = true</tt>. The default
# value is <tt>false</tt>. This value can be overridden at the class
# or instance level.
#
module Snapshottable
  extend ActiveSupport::Concern

  included do
    class_attribute :snapshottable
    self.snapshottable = false

    # do not dependent: :destroy, snapshots are not to be deleted for now.
    has_many :snapshots, as: :source
  end

  # Returns the current snapshot for the including model. When a snapshot_key
  # exists it will be used as a condition when searching for the snapshot. when
  # a snapshot_key does not exist it will return the most recent snapshot.
  def snapshot
    if snapshot_key
      snapshots.find_by(key: snapshot_key)
    else
      snapshots.order('created_at DESC').limit(1).first
    end
  end

  # +snapshot_key+ should be overridden by the including class to return
  # a value suitable for uniquely identifying that object at a point in time.
  # This is optional.See Attachment#snapshot_key for an example.
  def snapshot_key
    # no-op
  end

  # Returns true if a snapshot exists for the current model, otherwise false.
  def snapshotted?
    snapshot.present?
  end
end
