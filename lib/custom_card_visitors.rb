module CustomCardVisitors
  class CustomCardVisitor
    def visit(card_content); end

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
      @processed += list
    end

    def report
      dupes = @idents.select { |_ident, count| count > 1 }
      dupes.map { |ident, count| "Idents must be unique within a card; '#{ident}' occurs #{count} times" }
    end
  end

  require 'builder'
  class CardXmlGenerator < CustomCardVisitor
    def initialize(attributes, options = {})
      @attributes = attributes
      @indent = options[:indent] || 2
      @builder = options[:builder] || ::Builder::XmlMarkup.new(indent: @indent)
      @builder.instruct! unless options[:skip_instruct]
    end

    def visit(hierarchy)
      @builder.tag!('card', @attributes) do |xml|
        to_xml(xml, hierarchy.root)
      end
    end

    # If a text element contains & or < , wrap the content in a CDATA section.
    def render_text_tag(xml, tag, text)
      return nil if text.blank?
      if text =~ /(<|&)/
        xml.tag!(tag) { xml.cdata! text }
      else
        xml.tag!(tag, text)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def to_xml(xml, content)
      attrs = content.attributes.except(*%w[id instruction_text label text])
      validations = attrs.delete('validations') || []
      possible_values = attrs.delete('possible_values') || []

      @builder.tag!('content', attrs) do
        render_text_tag(xml, 'instruction-text', content.instruction_text)
        render_text_tag(xml, 'text', content.text)
        render_text_tag(xml, 'label', content.label)

        validations.each do |ccv|
          # Do not serialize the required-field validation, it is handled via the "required-field" attribute.
          next if ccv['validation_type'] == 'required-field'

          validation_attrs = { 'validation-type': ccv['validation_type'] }
          xml.tag!('validation', validation_attrs) do
            xml.tag!('error-message', ccv['error_message'])
            xml.tag!('validator', ccv['validator'])
          end
        end

        possible_values.each do |item|
          xml.tag!('possible-value', label: item['label'], value: item['value'])
        end

        content.children.each { |child| to_xml(xml, child) }
      end
    end
  end
end
