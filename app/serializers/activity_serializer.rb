class ActivitySerializer < ActiveModel::Serializer
  has_one :actor, include: false, embed: :id

  attributes :event_name,
             :message,
             :actor_full_name,
             :actor_avatar_url,
             :created_at,

  def actor_full_name
    actor.full_name
  end

  def actor_avatar_url
    actor.avatar_url
  end

  def created_at
    object.created_at.strftime('%B %e, %Y %l:%M %p')
  end

  #TODO move to client
  def message
    "Placeholder"
  end
end
