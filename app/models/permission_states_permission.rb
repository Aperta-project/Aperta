class PermissionStatesPermission < ActiveRecord::Base
  include ViewableModel
  belongs_to :permission_state
  belongs_to :permission
end
