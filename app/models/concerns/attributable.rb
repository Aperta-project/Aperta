module Attributable
  extend ActiveSupport::Concern

  CONTENT_ATTRIBUTES = {
    boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
    string:  %w[condition default_answer_value editor_style error_message
                instruction_text label text value_type visible_with_parent_answer],
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

        define_method(name) do
          attr = find_attribute_named(name)
          result = attr.try(&:value)
          # puts "Synthetic getter #{name}, returning #{result.class} #{result}"
          result
        end

        define_method("#{name}=") do |contents|
          attr = find_attribute_named(name)
          attr ||= content_attributes.new(name: name, value_type: ATTRIBUTE_CONTENTS[name])
          attr.value = contents
          attr.save! unless new_record?
          # puts "Synthetic setter #{name}, with #{contents.class} #{attr.value}"
          attr.value
        end
      end
    end

private

    def find_attribute_named(name)
      if new_record?
        content_attributes.detect { |each| each.name == name }
      else
        content_attributes.named(name)
      end
    end
  end
end
