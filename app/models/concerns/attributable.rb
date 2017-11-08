# rubocop:disable Style/PredicateName
# rubocop:disable Metrics/AbcSize
#
# Concern providing an entity-attribute-value model
# See CardContent model for an example of its use.
module Attributable
  extend ActiveSupport::Concern

  module ClassMethods
    # rubocop:disable Metrics/MethodLength
    def has_attributes(types)
      has_many :entity_attributes, dependent: :destroy, inverse_of: :entity, as: :entity
      types.each do |type, names|
        names.each do |name|
          getter = "#{name}_attribute".to_sym
          setter = "#{name}_attribute=".to_sym

          has_one getter, -> { where(name: name) }, class_name: EntityAttribute, as: :entity

          define_method(name) do
            if send(:entity_attributes).loaded?
              send(:entity_attributes).find { |a| a.name == name }.try(:value)
            else
              send(getter).try(:value)
            end
          end

          define_method("#{name}=") do |new_value|
            content_attribute = send(getter) || send(:entity_attributes).new(name: name, value_type: type)
            content_attribute.value = new_value.presence
            send(setter, content_attribute)
          end
        end
      end
    end
  end
end
