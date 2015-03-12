module Notifications
  class ActivitySerializer < ActiveModel::Serializer
    attributes :id, :event, :target, :actor, :created_at

    def event
      ["es", object.event_name].join("::")
    end

    def target
      { object.target_type.demodulize.underscore.to_sym => object.target_id }
    end

    def actor
      { user: object.actor.id }
    end
  end
end
