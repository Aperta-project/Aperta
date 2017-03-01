require_relative "./answer_creator"

module CardConfig
  class CardCreator

    attr_reader :owner_klass

    def initialize(owner_klass:)
      @owner_klass = owner_klass
    end

    def call
      Card.transaction do
        validate_card_content_idents!

        card.card_content.each do |cc|
          next if cc.ident.nil? # don't include the root node
          nested_question = NestedQuestion.find_by(ident: cc.ident)
          AnswerCreator.new(nested_question: nested_question, card_content: cc).call
        end

        # associate all instances of this owner to the newly created card / card_content
        owner_klass.update_all(card_id: card)

        card
      end
    end

    private

    def card
      @card ||= Card.find_or_create_by(name: owner_klass.name)
    end

    # We expect every ident in our cards to have a matching
    # NestedQuestion record in the database.
    def validate_card_content_idents!
      old_idents = Set.new(NestedQuestion.pluck(:ident))
      new_idents = Set.new(CardContent.where.not(ident: nil).pluck(:ident))

      if old_idents != new_idents
        fail <<-ERROR.strip_heredoc
          Expected to find CardContent with idents '#{old_idents.to_a}' in the database,
          but found '#{new_idents.to_a}'
        ERROR
      end
    end
  end
end
