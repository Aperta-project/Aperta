module Snapshottable
  extend ActiveSupport::Concern

  included do
    class_attribute :snapshottable
    self.snapshottable = false
  end
end
