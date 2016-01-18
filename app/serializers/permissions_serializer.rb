# Serializer for Roles and Permissions
class PermissionsSerializer < ActiveModel::Serializer
  def serializable_hash
    object.to_h.merge id: id
  end

  # This is needed to allow the permissions to side load. Works in
  # conjuction with `has_one :permissions, include: true, embed: :ids` on the
  # controller's serializer
  def id
    1
  end
end
