module CustomCardVisitors
  class CustomCardVisitor
    def visit(card_content); end
  end

  # This class flattens and de-dupes Rails errors in a content hierarchy

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

  # This class is useful for debugging idents in a content hierarchy

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

  # This class does semantic validation on a content hierarchy
  # - permit an IF component to have the same ident on both legs, but validate those against other components

  class CardSemanticValidator < CustomCardVisitor
    IGNORED = Set.new(%w[if]).freeze

    def initialize
      @idents = Hash.new(0)
      @processed = Set.new
    end

    def visit(card_content)
      return if remembered?(card_content.object_id)

      parent = card_content.parent
      if parent.present? && IGNORED.member?(parent.content_type)
        parent.children.map(&:ident).reject(&:blank?).uniq.each { |ident| @idents[ident] += 1 }
        remember(parent.children.map(&:object_id))
      elsif card_content.ident.present?
        @idents[card_content.ident] += 1
      end
    end

    def remembered?(item)
      @processed.member?(item)
    end

    def remember(list)
      list.each { |item| @processed.add(item) }
    end

    def report
      dupes = @idents.select { |_ident, count| count > 1 }
      dupes.map { |ident, count| "Idents must be unique within a card; '#{ident}' occurs #{count} times" }
    end
  end
end
