module CustomCardVisitors
  class CustomCardVisitor
    def visit(card_content)
    end
  end

  class CardErrorVisitor < CustomCardVisitor
    def initialize
      @errors = []
    end

    def visit(card_content)
      return unless card_content.invalid?
      @errors << card_content.errors.full_messages
    end

    def report
      @errors.flatten.uniq
    end
  end

  class CardIdentVisitor < CustomCardVisitor
    def initialize
      @idents = []
    end

    def visit(card_content)
      return if card_content.ident.blank?
      @idents << card_content.ident
    end

    def report
      @idents
    end
  end

  class CardSemanticValidator < CustomCardVisitor
    IGNORED = Set.new(%w(if)).freeze

    def initialize
      @idents = Hash.new(0)
    end

    def visit(card_content)
      return if card_content.ident.blank?
      parent = card_content.parent
      return if parent.present? && IGNORED.member?(parent.content_type)
      @idents[card_content.ident] += 1
    end

    def report
      dupes = @idents.select { |ident, count| count > 1 }
      dupes.map { |ident, count| "Idents must be unique within a card: #{ident} [#{count}]" }
    end
  end
end
