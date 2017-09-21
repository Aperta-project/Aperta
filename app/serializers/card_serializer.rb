# The CardSerializer is only used in an admin context at the moment. All of the
# card content for the latest version of the given card is serialized down as a
# single nested structure
class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :xml, :state, :addable, :workflow_only
  has_one :content, embed: :id, include: true, root: :card_contents
  has_many :card_versions, embed: :ids

  def content
    object.content_root_for_version(:latest)
  end

  # include_*? is a method that we can define for a given attribute that will
  # cause the serializer to omit the attribute if the method returns true. See
  # https://github.com/rails-api/active_model_serializers/tree/0-8-stable#attributes
  def include_content?
    @options[:include_content] != false
  end

  def include_xml?
    @options[:include_content] != false
  end

  def state
    object.state.camelize(:lower)
  end

  def addable
    object.addable?
  end

  def workflow_only
    object.latest_card_version.workflow_display_only
  end

  def xml
    object.to_xml.chomp
  end
end
