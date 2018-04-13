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
    el.xpath('*')
      .select { |child| child.name =~ /\A[A-Z]/ }
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
