# Answerable brings together a few bundled concepts, including belonging to a
# Card and owning Answers.  Anything that can store the Answer to a piece of
# CardContent also belongs to a Card.
module Answerable
  extend ActiveSupport::Concern

  module ClassMethods
    def answerable?
      true
    end
  end

  included do
    belongs_to :card

    before_destroy :destroy_answers

    # TODO APERTA-8972 Do we need to have a dependent: :destroy equivalent for
    # answers? Models like Authors and Funders are likely to be removed from the
    # system.  We don't want to leave orphans lying around
    has_many :answers, as: :owner

    def destroy_answers
      answers.destroy_all
    end

    def owner_type_for_answer
      self.class.name
    end
  end
end
