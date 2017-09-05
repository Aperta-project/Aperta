module Attributable
  extend ActiveSupport::Concern

  CONTENT_ATTRIBUTES = {
    boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
    string:  %w[child_tag condition custom_class custom_child_class default_answer_value
                editor_style error_message instruction_text label text value_type
                visible_with_parent_answer wrapper_tag],
    json:    %w[possible_values]
  }.freeze

  ATTRIBUTE_TYPES = CONTENT_ATTRIBUTES.each_with_object({}) do |(type, names), hash|
    names.each { |name| hash[name] = type }
  end.freeze

  included do
    has_many :content_attributes, dependent: :destroy, inverse_of: :card_content

    def content_attributes_hash
      content_attributes.each_with_object({}) { |each, hash| hash[each.name] = each.value }.compact
    end

    CONTENT_ATTRIBUTES.each do |type, names|
      names.each do |name|
        getter = "#{name}_attribute".to_sym
        setter = "#{name}_attribute=".to_sym

        has_one getter, -> { where(name: name) }, class_name: 'ContentAttribute'

        define_method(name) do
          send(getter).try(&:value)
        end

        define_method("#{name}=") do |new_value|
          content_attribute = content_attributes.where(name: name, value_type: ATTRIBUTE_TYPES[name]).first_or_initialize
          content_attribute.value = new_value
          send(setter, content_attribute)
        end
      end
    end
  end
end
