# The CardSerializer is only used in an admin context at the moment. All of the
# card content for the latest version of the given card is serialized down as a
# single nested structure
class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :xml, :state, :addable
  has_one :content, embed: :id, include: true, root: :card_contents
  has_many :card_versions, embed: :ids

  has_many :latest_contents, embed: :ids, include: true, root: :card_contents

  def latest_contents
    object.latest_card_version.card_contents
  end

  def content
    object.content_root_for_version(:latest)
  end

  def state
    object.state.camelize(:lower)
  end

  def addable
    object.addable?
  end

  def xml
    object.to_xml.chomp
  end
end
