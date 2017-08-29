class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :allow_multiple_uploads,
             :allow_file_captions,
             :content_type,
             :ident,
             :label,
             :order,
             :instruction_text,
             :possible_values,
             :text,
             :custom_child_class,
             :child_tag,
             :custom_class,
             :wrapper_tag,
             :value_type,
             :editor_style,
             :condition,
             :allow_annotations,
             :required_field,
             :default_answer_value,
             # when visible_with_parent_answer is set,
             # if the parent's answer is equal to this value
             # then render this content's children
             :visible_with_parent_answer,
             :error_message

  has_many :children,
           embed: :ids,
           include: true,
           root: :card_contents,
           key: :unsorted_child_ids

  def order
    object.lft
  end

  def default_answer_value
    return object.default_answer_value == 'true' ? true : false if object.value_type == 'boolean'
    object.default_answer_value
  end
end
