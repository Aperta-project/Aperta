class RepetitionSerializer < ActiveModel::Serializer
  attributes :id,
    :card_content_id,
    :task_id,
    :parent_id,
    :lft

  has_one :card_content, embed: :id
  has_one :task, embed: :id
end
