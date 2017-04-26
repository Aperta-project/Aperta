# Answerable brings together a few bundled concepts, including belonging to a
# Card and owning Answers.  Anything that can store the Answer to a piece of
# CardContent also belongs to a Card.
module Answerable
  extend ActiveSupport::Concern

  module ClassMethods
    def answerable?
      true
    end

    def latest_card_version
      Card.find_by_class_name!(self).latest_card_version
    end
  end

  included do
    belongs_to :card_version
    has_one :card, through: :card_version

    has_many :answers, as: :owner, dependent: :destroy
    validates :card_version_id, presence: true

    def owner_type_for_answer
      self.class.name
    end

    def answer_for(ident)
      answers.joins(:card_content).find_by(card_contents: { ident: ident })
    end

    def latest_card_version
      Card.find_by_class_name!(self.class).latest_card_version
    end

    # find_or_build_answer_for(...) will return the associated answer for this
    # task given the :card_content parameter.
    def find_or_build_answer_for(card_content:, value: nil)
      answer = answers.find_or_initialize_by(
        card_content: card_content,
        value: value
      )
      answer.paper = paper if respond_to?(:paper)

      answer
    end
  end
end
