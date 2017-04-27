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
    card = Card.find_by_class_name!(model_klass)
    answerables.update_all(card_version_id: card.latest_card_version.id)
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
end
