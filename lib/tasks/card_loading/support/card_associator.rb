require_relative "./card_factory"

# This class is responsible associating any ActiveRecord class (that
# has the answerable mixin) with a CardVersion.
#
# It is assumed this will be leveraged to associate any existing record
# (such as Tasks, GroupAuthors, etc.) with a Card.
#
class CardAssociator
  attr_accessor :model_klass, :answerables

  def initialize(model_klass)
    @model_klass = model_klass
    raise "#{model_klass} is not an answerable model" unless model_klass.try(:answerable?)
  end

  def process
    answerables.find_each do |answerable|
      card = find_card(answerable)
      raise "Could not find card for #{card_name}" if card.nil?
      answerable.update_attribute(:card_version_id, card.latest_card_version.id)
    end
  end

  def assert_all_associated!
    if answerables.reload.any?
      raise "Not all #{model_klass} have an associated CardVersion"
    end
  end

  private

  def answerables
    @answerables ||= model_klass.where(card_version_id: nil)
  end

  def find_card(answerable)
    @card ||= begin
      card_name = LookupClassNamespace.lookup_namespace(model_klass)
      Card.find_by(name: card_name)
    end
  end
end
