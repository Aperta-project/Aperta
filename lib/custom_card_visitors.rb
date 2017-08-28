module CustomCardVisitors
  class CustomCardVisitor
    def visit(_card_content)
      nil
    end

    def report
      []
    end

    def to_s
      "#{self.class.name} #{report}"
    end
  end

  # This class flattens and de-dupes Rails errors in a content hierarchy.

  class CardErrorVisitor < CustomCardVisitor
    def initialize
      @errors = Set.new
    end

    def visit(card_content)
      return unless card_content.invalid?
      @errors << card_content.errors.full_messages
    end

    def report
      @errors.to_a
    end
  end

  # This class is useful for debugging idents in a content hierarchy.

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

  # Permit an IF component to have the same ident on both legs,
  # but validate those against other components.

  class IfComponentValidator < CustomCardVisitor
    IF_CONTENT = 'if'.freeze

    def initialize
      @processed = Set.new
      @idents = Hash.new(0)
    end

    def remembered?(item)
      @processed.member?(item)
    end

    def remember(list)
      @processed += list
    end

    def visit(card_content)
      return if remembered?(card_content.object_id)
      parent = card_content.parent
      if parent.present? && IF_CONTENT == parent.content_type
        parent.children.map(&:ident).reject(&:blank?).uniq.each { |ident| idents[ident] += 1 }
        remember(parent.children.map(&:object_id))
      elsif card_content.ident.present?
        @idents[card_content.ident] += 1
      end
    end

    def report
      dupes = @idents.select { |_ident, count| count > 1 }
      dupes.map { |ident, count| "Idents must be unique within a card; '#{ident}' occurs #{count} times" }
    end
  end

  # Nested repeat components are explicitly disallowed for now.

  class RepeatComponentValidator < CustomCardVisitor
    REPEAT_CONTENT = 'repeat'.freeze

    def initialize
      @errors = Set.new
    end

    def visit(card_content)
      repeat = card_content.of_type(REPEAT_CONTENT)
      return if repeat.blank?
      return if repeat.object_id == card_content.object_id
      @errors << "'Repeat' components may not be nested."
    end

    def report
      @errors.to_a
    end
  end
end
