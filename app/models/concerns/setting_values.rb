# SettingValues holds common validations and accessors that are used in
# Setting, SettingTemplate, and PossibleSettingValue.
# Each model gets and sets a 'value' which may be one of several underlying
# types. Rather than storing the value in a string column and casting it we've
# chosen to store a value_type and to shove the value into the appropriately
# typed column.
module SettingValues
  extend ActiveSupport::Concern

  included do
    validates :value_type,
              presence: true,
              inclusion: { in: %w(string integer boolean) }

    def value
      value_method_name = "#{value_type}_value".to_sym
      send value_method_name
    end

    def value=(new_value)
      value_method_name = "#{value_type}_value=".to_sym
      send value_method_name, new_value
    end
  end
end
