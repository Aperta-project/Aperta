# Base class and registry for actions that are triggered by events in Tahi.
class BehaviorAction
  def self.call(event_params:, behavior_params:) # rubocop:disable Lint/UnusedMethodArgument
    raise NotImplementedError
  end
end
