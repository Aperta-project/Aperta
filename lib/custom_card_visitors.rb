module CustomCardVisitors
  class CustomCardVisitor
    def enter(card_content); end
    def visit(card_content); end
    def leave(card_content); end

    def to_s
      "#{self.class.name} #{report}"
    end
  end

  # This class flattens and de-dupes Rails errors in a content hierarchy

  class CardErrorVisitor < CustomCardVisitor
    def initialize
      @errors = []
    end

    def visit(card_content)
      return if card_content.valid?
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

  # This class ensures that idents are unique within a card,
  # except IF components, which can have the same ident on both legs.

  class CardIfIdentValidator < CustomCardVisitor
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
      @processed += list
    end

    def report
      dupes = @idents.select { |_ident, count| count > 1 }
      dupes.map { |ident, count| "Idents must be unique within a card; '#{ident}' occurs #{count} times" }
    end
  end

  # IF components that test for isEditable cannot have children with a value-type attribute.

  class CardIfConditionValidator < CustomCardVisitor
    COMPONENTS = Set.new(%w[if]).freeze
    CONDITIONS = Set.new(%w[isEditable]).freeze

    def initialize
      @nesting = 0
      @errors = 0
    end

    def enter(card_content)
      remember if interesting?(card_content)
    end

    def visit(card_content)
      return unless nested?
      return unless answerable?(card_content)
      @errors += 1
    end

    def leave(card_content)
      forget if interesting?(card_content)
    end

    def report
      return [] if @errors.zero?
      ["#{COMPONENTS.to_a.join(', ')} components with #{CONDITIONS.to_a.join(', ')} conditions may not contain value-type child components"]
    end

    private

    def nested?
      @nesting > 0
    end

    def remember
      @nesting += 1
    end

    def forget
      @nesting -= 1
    end

    def answerable?(card_content)
      card_content.value_type.present?
    end

    def interesting?(card_content)
      COMPONENTS.member?(card_content.content_type) && CONDITIONS.member?(card_content.condition)
    end
  end
end
