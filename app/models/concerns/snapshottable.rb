module Snapshottable
  extend ActiveSupport::Concern

  included do
    class_attribute :snapshottable
    self.snapshottable = false
  end

  # +snapshot_key+ should be overridden by the including class to return
  # a value suitable for uniquely identifying that object at a point in time.
  # This is optional.See Attachment#snapshot_key for an example.
  def snapshot_key
    # no-op
  end
end
