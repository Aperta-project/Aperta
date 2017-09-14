class ContentNode
  attr_accessor :id, :content, :children

  def initialize(content)
    @id = id
    @content = content
    @children = []
  end

  %w[ident content_type attributes validations].each do |name|
    define_method(name) do
      content[name]
    end

    define_method("#{name}=") do |value|
      content[name] = value
    end
  end

  def traverse(visitor)
    visitor.visit(self)
    children.each {|child| visitor.visit(child)}
  end

  def content_attrs
    attrs = COMMON_ATTRIBUTES.each_with_object { |name, hash| hash[name] = content[RUBY_ATTRIBUTES[name]] }
    attrs.merge(additional_content_attrs).compact
  end

  def additional_content_attrs
    CUSTOM_ATTRIBUTES[content_type].each_with_object { |name, hash| hash[name] = content[RUBY_ATTRIBUTES[name]] }.compact
  end
end

class ContentHierarchy
  include AttributeNames
  attr_accessor :root

  def initialize(root)
    @root = root
  end

  def traverse(visitor)
    visitor.visit(root)
  end

  def render_tag(xml, tag, text)
    return nil if text.blank?
    if text =~ /(<|&)/
      xml.tag!(tag) { xml.cdata! text }
    else
      xml.tag!(tag, text)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def to_xml(options = {})
    setup_builder(options).tag!('content', content_attrs) do |xml|
      render_tag(xml, 'instruction-text', instruction_text)
      render_tag(xml, 'text', text)
      render_tag(xml, 'label', label)
      card_content_validations.each do |ccv|
        # Do not serialize the required-field validation, it is handled via the
        # "required-field" attribute.
        next if ccv.validation_type == 'required-field'
        create_card_config_validation(ccv, xml)
      end
      if possible_values.present?
        possible_values.each do |item|
          xml.tag!('possible-value', label: item['label'], value: item['value'])
        end
      end
      children.each { |child| child.to_xml(builder: xml, skip_instruct: true) }
    end
  end
end
