# Answerable brings together a few bundled concepts, including belonging to a
# Card and owning Answers.  Anything that can store the Answer to a piece of
# CardContent also belongs to a Card.
module Answerable
  extend ActiveSupport::Concern

  module ClassMethods
    def answerable?
      true
    end

    # TODO: Remove this when there is not a 1-1 relationship between a
    # descendent of Task and an instance of a Card.
    # Returns the card instance for this Task class.
    def card_for
      Card.find_by_name(name.to_s)
    end
  end

  included do
    belongs_to :card

    has_many :answers, as: :owner, dependent: :destroy

    def owner_type_for_answer
      self.class.name
    end

    def answer_for_ident(ident)
      answers.joins(:card_content).find_by(card_contents: { ident: ident } )
    end
  end
end
