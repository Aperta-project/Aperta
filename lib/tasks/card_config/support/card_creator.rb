require_relative "./answer_creator"

module CardConfig
  class CardCreator
    attr_reader :owner_klass

    def initialize(owner_klass:)
      @owner_klass = owner_klass
    end

    def call
      Card.transaction do
        Card.find_by_name(owner_klass.name).latest_card_version.card_content.descendants do |cc|
          nested_question = NestedQuestion.find_by(ident: cc.ident)
          AnswerCreator.new(nested_question: nested_question, card_content: cc).call
        end

        # associate all instances of this owner to the newly created card / card_content
        owner_klass.update_all(card_id: card)

        card
      end
    end
  end
end
