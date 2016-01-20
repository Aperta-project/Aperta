# Serializer for Roles and Permissions
class PermissionsSerializer < ActiveModel::Serializer
  def serializable_hash
    object.to_h.merge(id: id).as_json
  end

  # The +id+ here is hard-coded to side-loading. It works in conjuction with
  # the`has_one :permissions, include: true, embed: :ids` on the
  # CurrentUserSerializer.
  #
  # This is because ember-data expects resources on the server to have numeric
  # IDs by default otherwise it gets angry. Rather than work against the grain
  # of ember-data right now we're working with it. This may change in upcoming
  # work if this has cause other issues. Perhaps to not use ember-data for
  # permissions on the client-side (maybe restless) and then we could get rid
  # of a fake id.
  def id
    1
  end
end
