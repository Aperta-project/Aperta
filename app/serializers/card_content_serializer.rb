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
             :value_type,
             :editor_style,
             :condition,
             :allow_annotations,
             :required_field,
             :default_answer_value,
             :initial,
             :min,
             :max,
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
end
