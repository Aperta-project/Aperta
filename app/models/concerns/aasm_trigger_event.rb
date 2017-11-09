module AASMTriggerEvent
  extend ActiveSupport::Concern

  included do
    def trigger_aasm_event(aasm, **args)
      Event.trigger(
        "#{self.class.name.underscore}.state_changed.#{aasm.to_state}",
        activity_message: "Paper state changed to #{aasm.to_state}",
        from_state: aasm.from_state,
        to_state: aasm.to_state,
        **args
      )
    end
  end
end
