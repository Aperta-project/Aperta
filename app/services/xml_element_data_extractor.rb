# This class acts as a wrapper for a Nokogiri element that
# undertands how to extract data from it to put it into a
# domain context.  It is currently used by the XMLCardLoader.
class XmlElementDataExtractor
  attr_accessor :el

  def initialize(el)
    @el = el
  end

  def child_elements(name = '/')
    el.xpath(name).map { |child| self.class.new(child) }
  end

  def attr_value(name)
    el.attributes[name].try(:value)
  end

  def tag_text(tag)
    el.xpath(tag).first.try(:text).try(:strip)
  end

  # returns an array of hashes that contains each key and value
  # example: pluck_values('possible-value', [:label, :value])
  #  -> [{label: 'state', value: 'ohio'}, {label: 'at home', value: 'false'}]
  def fetch_values(name, keys = [])
    el.xpath(name).each_with_object([]) do |pv_el, ary|
      ary << keys.each_with_object({}) do |key, hsh|
        hsh[key] = pv_el.attributes[key.to_s].try(:value)
      end
    end
  end
end
