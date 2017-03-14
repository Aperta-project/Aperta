require_relative "./answer_migrator"

module CardConfig
  class CardMigrator
    attr_reader :owner_klass

    def initialize(owner_klass:)
      @owner_klass = owner_klass
    end

    def call
      Card.transaction do
        card = Card.find_by_name(owner_klass.name)
        return unless card
        card.latest_card_version.card_content.descendants.all.each do |cc|
          puts "migrating #{cc.ident}"
          nested_question = NestedQuestion.find_by(ident: cc.ident)
          AnswerMigrator.new(nested_question: nested_question, card_content: cc).call
        end

        # associate all instances of this owner to the newly created card / card_content
        owner_klass.update_all(card_version_id: card.latest_card_version.id)

        card
      end
    end
  end
end
