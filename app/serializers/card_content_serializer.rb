class CardContentSerializer < ActiveModel::Serializer
  def self.content_attribute(name)
    define_method name do
      cached_content_attribute(name)
    end

    define_method "include_#{name}?".to_sym do
      send(name).present?
    end

    attribute name
  end

  def self.content_attributes(names)
    names.each do |n|
      content_attribute n
    end
  end

  def cached_content_attribute(name)
    @c ||= object.content_attributes.to_a
    @c.find { |c| c.name == name.to_s }.try(:value)
  end

  attributes :id,
             :card_version_id,
             :content_type,
             :ident,
             :order,

  has_many :children,
           embed: :ids,
           include: true,
           root: :card_contents,
           key: :unsorted_child_ids
  content_attributes [
    :allow_annotations,
    :allow_file_captions,
    :allow_multiple_uploads,
    :required_field,
    :possible_values,
    :child_tag,
    :condition,
    :custom_class,
    :custom_child_class,
    :editor_style,
    :error_message,
    :instruction_text,
    :key,
    :label,
    :text,
    :value_type,
    :visible_with_parent_answer,
    :wrapper_tag
  ]

  def order
    object.lft
  end

  def default_answer_value
    default = cached_content_attribute(:default_answer_value)
    return default == 'true' ? true : false if default.present? && value_type == 'boolean'
    default
  end
end
