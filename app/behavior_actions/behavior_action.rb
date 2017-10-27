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

  def self.required_parameters(**kwargs) # rubocop:disable Style/TrivialAccessors
    @required_parameters = kwargs
  end

  def self.mk_validators
    @registry.map do |action_name, action_klass|
      required_params = action_klass.instance_variable_get(:@required_parameters)
      klass = Class.new(ActiveModel::Validator)
      klass.class_eval do
        define_method :validate do |record|
          return unless record.action.to_s == action_name.to_s
          required_params.each do |name, type|
            if record.try(name).try(:value_type) != type
              record.errors[:base] << "Required attribute #{name} for #{action_name} was not present"
            end
          end
        end
      end
      klass
    end
  end
end
