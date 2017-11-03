# rubocop:disable Style/PredicateName
# rubocop:disable Metrics/AbcSize
#
# Concern providing an entity-attribute-value model
# See CardContent model for an example of its use.
module Attributable
  extend ActiveSupport::Concern

  module ClassMethods
    # rubocop:disable Metrics/MethodLength
    def has_attributes(relation_name, class_name: nil, types:, inverse_of:)
      has_many relation_name, dependent: :destroy, inverse_of: inverse_of
      class_name ||= relation_name.to_s.singularize.camelize.constantize
      types.each do |type, names|
        names.each do |name|
          getter = "#{name}_attribute".to_sym
          setter = "#{name}_attribute=".to_sym

          has_one getter, -> { where(name: name) }, class_name: class_name

          define_method(name) do
            if send(relation_name).loaded?
              send(relation_name).find { |a| a.name == name }.try(:value)
            else
              send(getter).try(:value)
            end
          end

          define_method("#{name}=") do |new_value|
            content_attribute = send(getter) || send(relation_name).new(name: name, value_type: type)
            content_attribute.value = new_value.presence
            send(setter, content_attribute)
          end
        end
      end
    end
  end
end
