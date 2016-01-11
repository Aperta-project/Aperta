# Serializer for Roles and Permissions
class PermissionSerializer < ActiveModel::Serializer
  def serializable_hash
    object.to_h
  end

  def id
    1
  end
end
