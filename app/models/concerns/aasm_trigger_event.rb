# rubocop:disable Style/PredicateName
module AASMTriggerEvent
  extend ActiveSupport::Concern

  included do
    aasm do
      after_all_transitions :trigger_event
    end

    def trigger_event(user)
      Event.trigger("#{self.class.name.underscore}_#{aasm.current_event}",
                    paper: self,
                    user: user,
                    from_state: aasm.from_state,
                    to_state: aasm.to_state)
    end
  end
end
