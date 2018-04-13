# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

  # Idents must be unique within a card, except IF components, which can have the same ident on both legs.

  class CardIfIdentValidator < CustomCardVisitor
    COMPONENTS = Set.new(%w[if]).freeze

    def initialize
      @idents = Hash.new(0)
      @processed = Set.new
    end

    def visit(card_content)
      return if remembered?(card_content.object_id)

      parent = card_content.parent
      if parent.present? && COMPONENTS.member?(parent.content_type)
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
      components = COMPONENTS.to_a.sort.join(', ')
      conditions = CONDITIONS.to_a.sort.join(', ')
      ["#{components} components with #{conditions} conditions may not contain value-type child components"]
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
