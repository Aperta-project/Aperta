# Serializer for Roles and Permissions
class PermissionsSerializer < ActiveModel::Serializer
  def serializable_hash
    object.to_h
  end

  def id
    1
  end
end
