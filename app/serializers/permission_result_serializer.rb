##
# Serializer for a single, reified permission as returned by
# user#filter_authorized
#
class PermissionResultSerializer < ActiveModel::Serializer
  def serializable_hash
    {
      id: object.id,
      permissions: object.permissions
    }
  end
end
