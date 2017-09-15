class ContentNode
  attr_accessor :id, :content, :children

  def initialize(content)
    @id = id
    @content = content
    @children = []
  end

  def root?
    false
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

  def attributes
    content
  end

  def validations
    content['validations'] || []
  end

  def to_json
    content.to_json
  end

  def traverse(visitor)
    visitor.visit(self)
    children.each {|child| child.traverse(visitor)}
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

  def root?
    true
  end

  def to_xml
    traverse(CustomCardVisitors::CardXmlGenerator.new)
  end

  def traverse(visitor)
    visitor.visit(root)
  end
end
