class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
end
