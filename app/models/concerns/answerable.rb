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
    belongs_to :card_version

    has_many :answers, as: :owner, dependent: :destroy

    def owner_type_for_answer
      self.class.name
    end

    # The card method lets us account for both the old and new worlds.
    # If a task belongs to a new, user-generated card then it will have
    # a CardVersion, and we can get the card from there.  If it's an old
    # Task (say, the TahiStandardTasks::ReviewerReportTask) that is still
    # rendering hardcoded content, the task won't have a CardVersion, and
    # it should just look up the Card we've generated using the 'card_load:load'
    # rake task
    def card
      if card_version_id
        card_version.card
      else
        Card.lookup_card(self.class.name)
      end
    end
  end
end
