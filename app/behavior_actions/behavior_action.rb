# Base class and registry for actions that are triggered by events in Tahi.
class BehaviorAction
  def self.register(action_name, klass)
    @registry ||= {}
    @registry[action_name] = klass
  end

  def self.action_names
    @registry.keys
  end

  def self.find(action)
    @registry[action.to_sym]
  end
end
