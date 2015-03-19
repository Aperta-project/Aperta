module Notifications
  class Collapser
    attr_reader :inbox, :event_names

    def initialize(inbox:, event_names:)
      @inbox = inbox
      @event_names = [event_names].flatten
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

    # undissmissed activities for given event_names
    def unread_activities
      @activities ||= Activity.where(id: inbox.get).with_event_names(event_names)
    end
  end
end
