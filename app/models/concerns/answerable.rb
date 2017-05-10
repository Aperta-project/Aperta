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
    has_one :card, through: :card_version
    has_many :answers, as: :owner, dependent: :destroy

    delegate :latest_published_card_version, to: :card, allow_nil: true

    validates :card_version_id, presence: true

    before_validation :set_card_version

    def owner_type_for_answer
      self.class.name
    end

    def answer_for(ident)
      answers.joins(:card_content).find_by(card_contents: { ident: ident })
    end

    # when a new Answerable model is being created, this is the
    # Card that is used to determine the correct CardVersion.
    # This method can be overriden by the model, if a custom lookup
    # is necesssary.
    def default_card
      Card.find_by_class_name!(self.class.name)
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

    private

    # when new card versions are being created, associate the Answerable
    # model to the latest version of the Card.
    def set_card_version
      self.card_version ||= default_card.try(:latest_published_card_version)
    end
  end
end
