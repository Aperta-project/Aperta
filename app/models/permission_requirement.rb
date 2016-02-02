class PermissionRequirement < ActiveRecord::Base
  belongs_to :permission
  belongs_to :required_on, polymorphic: true
end
