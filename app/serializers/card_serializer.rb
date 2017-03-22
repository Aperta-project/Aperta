# The CardSerializer is only used in an admin context at the moment. All of the
# card content for the latest version of the given card is serialized down as a
# single nested structure
class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id
  has_one :content, embed: :id, include: true, root: :card_contents

  def content
    object.content_root_for_version(:latest)
  end
end
