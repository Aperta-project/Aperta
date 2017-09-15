class CardVersionSerializer < ActiveModel::Serializer
  attributes :id, :version, :card_id,
             :history_entry, :published_by, :published_at,
             :content_root_id
  has_many :card_contents, embed: :ids, include: true

  def published_by
    object.published_by.try(:full_name)
  end

  def content_root_id
    card_contents.where(parent_id: nil).first.id
  end
end
