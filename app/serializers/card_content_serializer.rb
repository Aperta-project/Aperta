class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :ident,
             :text,
             :value_type,
             :content_type,
             :order,
             :placeholder,
             :possible_values,
             # when visible_with_parent_answer is set,
             # if the parent's answer is equal to this value
             # then render this content's children
             :visible_with_parent_answer
  has_many :children,
           embed: :ids,
           include: true,
           root: :card_contents,
           key: :unsorted_child_ids

  def order
    object.lft
  end
end
