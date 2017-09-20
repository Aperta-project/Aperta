class ContentNode
  attr_accessor :content, :children

  def initialize(content)
    @content = content
    @children = []
  end

  Attributable::ATTRIBUTE_NAMES.each do |name|
    if Attributable::ATTRIBUTE_TYPES[name] == 'boolean'
      define_method(name) do
        content[name] == 'true'
      end

      define_method("#{name}=") do |value|
        content[name] = value.to_s
      end
    else
      define_method(name) do
        content[name]
      end

      define_method("#{name}=") do |value|
        content[name] = value
      end
    end
  end

  def to_hash
    @children.blank? ? attributes : attributes.merge(children: children.map { |child| child.to_hash })
  end

  def attributes
    content
    .reject  { |key, value| value.blank? }
    .collect { |key, value| [key.dasherize, value] }.to_h
  end

  def validations
    content['validations'] || []
  end

  def traverse(visitor)
    visitor.visit(self)
    children.each { |child| child.traverse(visitor) }
  end

  def to_ruby(name)
    Attributable::RUBY_ATTRIBUTES[name]
  end

  def to_xml(name)
    Attributable::XML_ATTRIBUTES[name]
  end
end

class ContentHierarchy
  attr_accessor :root

  def initialize(root)
    @root = root
  end

  def to_json
    root.to_hash.to_json
  end

  def to_xml(attrs)
    visitor = CustomCardVisitors::CardXmlGenerator.new(attrs)
    traverse(visitor)
  end

  def traverse(visitor)
    visitor.visit(self)
  end
end
