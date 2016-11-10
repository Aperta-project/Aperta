class PermissionStatesPermission < ActiveRecord::Base
  belongs_to :permission_state
  belongs_to :permission
end
