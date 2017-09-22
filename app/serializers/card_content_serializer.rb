class CardContentSerializer < ActiveModel::Serializer
  attributes(*Attributable::SERIAL_NAMES + %w[id order])

  has_many :children,
           embed: :ids,
           include: true,
           root: :card_contents,
           key: :unsorted_child_ids

  def order
    object.lft
  end

  def default_answer_value
    return object.default_answer_value == 'true' ? true : false if object.default_answer_value.present? && object.value_type == 'boolean'
    object.default_answer_value
  end
end
