module Attributable
  extend ActiveSupport::Concern

  CONTENT_ATTRIBUTES = {
    boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
    string:  %w[child_tag condition custom_class custom_child_class default_answer_value
                editor_style error_message instruction_text label text value_type
                visible_with_parent_answer wrapper_tag],
    json:    %w[possible_values]
  }.freeze

  # rubocop:disable Style/MutableConstant
  ATTRIBUTE_CONTENTS = {}
  # rubocop:enable Style/MutableConstant

  included do
    has_many :content_attributes, dependent: :destroy, inverse_of: :card_content

    def content_attributes_hash
      content_attributes.inject({}) {|hash, each| hash[each.name] = each.value; hash}.compact
    end

    CONTENT_ATTRIBUTES.each do |type, names|
      names.each do |name|
        ATTRIBUTE_CONTENTS[name] = type

        getter = "#{name}_attribute".to_sym
        setter = "#{name}_attribute=".to_sym
        has_one getter, -> { where(name: name) }, class_name: 'ContentAttribute'

        define_method(name) do
          send(getter).try(&:value)
        end

        define_method("#{name}=") do |contents|
          attr = send(getter)
          if contents.blank?
            attr.destroy if attr
            reload unless new_record?
            return contents
          end

          unless attr
            attr = content_attributes.new(name: name, value_type: ATTRIBUTE_CONTENTS[name])
            send(setter, attr)
          end

          attr.value = contents
          attr.save! unless new_record?
          attr.value
        end
      end
    end
  end
end
