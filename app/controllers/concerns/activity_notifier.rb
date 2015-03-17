module ActivityNotifier
  extend ActiveSupport::Concern

  included do
    def broadcast(event_name:, target:, scope:, region_name: nil, public: true, actor: current_user)

      activity = Activity.create!(
        event_name: event_name,   # the event name ("paper::revised" or "task::completed")
        target: target,           # the model that was changed (Paper or Task)
        region_name: region_name, # the contextual area that the activity is appropriate ("paper" or "workflow")
        scope: scope,             # the model that the target will be searched by for viewing (Paper)
        actor: actor,             # the User model that performed the change
        public: public            # true = shown in activity feed overlay, false = not shown
      )

      TahiNotifier.notify(event: event_name, payload: { activity: activity })
    end
  end
end
