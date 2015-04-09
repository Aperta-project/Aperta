module Notifications
  class Collapser
    attr_reader :inbox, :activity_resource

    def initialize(inbox:, activity_resource: nil)
      @inbox = inbox
      @activity_resource = activity_resource
    end

    # discard any undismissed notifications from the user's inbox
    def discard!
      inbox.remove(superceded_activities.pluck(:id))
    end

    # most recent undismissed activities for a given event_name and target
    def latest_activities
      unread_activities.select("DISTINCT ON (event_name, target_id, target_type) activities.*")
                       .order(:event_name, :target_id, :target_type, created_at: :desc)
    end

    # undismissed activities that have a more recent undismissed activity
    def superceded_activities
      unread_activities.where.not(id: latest_activities.flat_map(&:id))
    end

    # undissmissed activities for given event_names for a given active_resource scope
    def unread_activities
      @activities ||= Activity.where(id: inbox.get).for_target(activity_resource)
    end
  end
end
