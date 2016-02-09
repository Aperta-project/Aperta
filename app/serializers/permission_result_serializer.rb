##
# Serializer for a single, reified permission as returned by
# user#filter_authorized
#
class PermissionResultSerializer < ActiveModel::Serializer
  def serializable_hash(*args)
    hash = super(*args)
    hash.merge(
      id: object.id,
      object: object.object,
      permissions: object.permissions
    )
  end
end
