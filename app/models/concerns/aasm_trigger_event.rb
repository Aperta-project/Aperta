module AASMTriggerEvent
  extend ActiveSupport::Concern

  module ClassMethods
    def register_events!
      StateChangeEvent.register(*aasm.states.map(&:name).map { |s| make_event_name(s) })
    end

    # TODO: This should be based on the event, not the state
    def make_event_name(state)
      "#{name.underscore}.state_changed.#{state}"
    end
  end
end
