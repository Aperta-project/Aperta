class PermissionsRole < ActiveRecord::Base
  include ViewableModel
  belongs_to :role
  belongs_to :permission
end
