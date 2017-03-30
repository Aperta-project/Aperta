require_relative "./answer_migrator"

module CardConfig
  class CardMigrator
    attr_reader :card_name

    def initialize(card_name)
      @card_name = card_name
    end

    def call
      Card.transaction do
        card = Card.find_by_name(card_name)
        return unless card
        card.card_version(:latest).content_root.descendants.all.each do |cc|
          puts "migrating #{cc.ident}"
          nested_question = NestedQuestion.find_by(ident: cc.ident)
          AnswerMigrator.new(nested_question: nested_question, card_content: cc).call
        end
        card
      end
    end
  end
end
