module AASMTriggerEvent
  extend ActiveSupport::Concern

  included do
    def trigger_aasm_event(aasm, **args)
      Event.trigger(
        self.class.make_event_name(aasm.to_state),
        activity_message: "Paper state changed to #{aasm.to_state}",
        from_state: aasm.from_state,
        to_state: aasm.to_state,
        **args
      )
    end
  end

  module ClassMethods
    def register_events!
      Event.register(*aasm.states.map(&:name).map { |s| make_event_name(s) })
    end

    # TODO: This should be based on the event, not the state
    def make_event_name(state)
      "#{name.underscore}.state_changed.#{state}"
    end
  end
end
