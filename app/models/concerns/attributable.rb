module Attributable
  extend ActiveSupport::Concern

  CONTENT_ATTRIBUTES = {
    boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
    json:    %w[possible_values],
    string:  %w[child_tag condition custom_class custom_child_class default_answer_value
                editor_style error_message instruction_text key label text value_type
                visible_with_parent_answer wrapper_tag min max delete_button_label
                add_button_label]
  }.freeze

  included do
    has_many :content_attributes, dependent: :destroy, inverse_of: :card_content

    CONTENT_ATTRIBUTES.each do |type, names|
      names.each do |name|
        getter = "#{name}_attribute".to_sym
        setter = "#{name}_attribute=".to_sym

        has_one getter, -> { where(name: name) }, class_name: 'ContentAttribute'

        define_method(name) do
          if content_attributes.loaded?
            content_attributes.find { |a| a.name == name }.try(:value)
          else
            send(getter).try(:value)
          end
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
