module Notifications
  class ActivitySerializer < ActiveModel::Serializer
    # TODO: Reassess naming of notification, event, activity
    root :event
    attributes :id, :name, :target, :actor, :created_at

    def name
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
