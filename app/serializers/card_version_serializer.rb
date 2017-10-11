class CardVersionSerializer < ActiveModel::Serializer
  attributes :id, :version, :card_id,
             :history_entry, :published_by, :published_at
  has_one :content_root, embed: :id, include: true, root: :card_contents
  has_many :contents, embed: :ids, include: true, root: :card_contents

  def published_by
    object.published_by.try(:full_name)
  end

  def contents
    @contents ||= object.content_root.preload_descendants
  end
end
