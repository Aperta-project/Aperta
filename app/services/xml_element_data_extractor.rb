# This class acts as a wrapper for a Nokogiri element that
# undertands how to extract data from it to put it into a
# domain context.  It is currently used by the XMLCardLoader.
class XmlElementDataExtractor
  attr_accessor :el

  def initialize(el)
    @el = el
  end

  def element_name
    @el.name
  end

  def child_elements(name = '/')
    el.xpath(name).map { |child| self.class.new(child) }
  end

  def child_content_elements
    # Select any elements which begin with a capital letter because currently only cardContents have that casing
    # child.name == "content" may be vestigal or intended to handle legacy cases. Chris westra can confirm
    el.xpath('*')
      .select { |child| child.name =~ /\A[A-Z]/ || child.name == "content" }
      .map { |child| self.class.new(child) }
  end

  def attr_value(name)
    el.attributes[name].try(:value)
  end

  def tag_text(tag)
    el.xpath(tag).first.try(:text).try(:strip)
  end

  def tag_xml(tag)
    el.xpath(tag).first.try(:children).try(:to_xml,
       save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
  end

  # fetch_values will map over an array of child elements with the given `name`
  # and extract the attributes for the provided keys.
  # ex: for
  #   <possible-value label="foo" value="bar" />
  #   <possible-value label="baz" value="dude" />
  # fetch_values('possible-value', [:label, :value]) will return:
  #   [{label: 'state', value: 'ohio'}, {label: 'at home', value: 'false'}]
  def fetch_values(name, keys = [])
    el.xpath(name).each_with_object([]) do |pv_el, ary|
      ary << keys.each_with_object({}) do |key, hsh|
        hsh[key] = pv_el.attributes[key.to_s].try(:value)
      end
    end
  end
end
