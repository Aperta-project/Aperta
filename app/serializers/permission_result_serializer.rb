##
# Serializer for a single, reified permission as returned by
# user#filter_authorized
#
class PermissionResultSerializer < ActiveModel::Serializer
  def serializable_hash(*args)
    hash = super(*args)
    hash.merge(
      id: "#{object.object[:type].demodulize
                                 .camelize(:lower)}+#{object.object[:id]}",
      object: {
        id: object.object[:id],
        type: object.object[:type].demodulize
      },
      permissions: object.permissions
    )
  end
end
