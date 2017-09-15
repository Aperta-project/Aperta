module Attributable
  extend ActiveSupport::Concern

  # Ruby attribute format: snake_case, column and method names
  BASE_ATTRIBUTES = %w[ident content_type validations].freeze

  CONTENT_ATTRIBUTES = {
    boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
    integer: %w[],
    json:    %w[possible_values],
    string:  %w[child_tag condition custom_class custom_child_class default_answer_value
                editor_style error_message instruction_text label text value_type
                visible_with_parent_answer wrapper_tag]
  }.freeze

  CONTENT_TYPES   = CONTENT_ATTRIBUTES.keys.freeze
  ATTRIBUTE_TYPES = CONTENT_ATTRIBUTES.each_with_object({}) { |(type, name), hash| hash[name] = type.to_s }.freeze
  ATTRIBUTE_NAMES = Set.new(BASE_ATTRIBUTES + CONTENT_ATTRIBUTES.values.flatten).freeze

  # Convert between formats
  XML_ATTRIBUTES  = Hash[ATTRIBUTE_NAMES.map { |name| [name.tr('-', '_'), name] }].freeze
  RUBY_ATTRIBUTES = Hash[ATTRIBUTE_NAMES.map { |name| [name, name.tr('-', '_')] }].freeze

  # XML attribute format: kabob-case, element and attribute names
  COMMON_ATTRIBUTES = %w[allow-annotations instruction-text label required-field].freeze
  CUSTOM_ATTRIBUTES = [
    [%w[file-uploader],   %w[allow-file-captions allow-multiple-uploads]],
    [%w[if],              %w[condition]],
    [%w[paragraph-input], %w[editor-style]],
    [%w[date-picker],     %w[required-field]],
    [%w[check-box drop-down radio short-input tech-check], %w[]]
  ].each_with_object(Hash.new([])) do |(types, attributes), hash|
    types.each { |type| hash[type] += attributes + COMMON_ATTRIBUTES }
  end.freeze

  included do
    has_many :content_attributes, dependent: :destroy, inverse_of: :card_content

    CONTENT_ATTRIBUTES.each do |type, names|
      names.each do |name|
        getter = "#{name}_attribute".to_sym
        setter = "#{name}_attribute=".to_sym

        has_one getter, -> { where(name: name) }, class_name: 'ContentAttribute'

        define_method(name) do
          send(getter).try(:value)
        end

        define_method("#{name}=") do |new_value|
          content_attribute = send(getter) || content_attributes.new(name: name, value_type: type)
          content_attribute.value = new_value.presence
          send(setter, content_attribute)
        end
      end
    end
  end
end
