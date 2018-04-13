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

# A Scrubber that scrubs out bad HTML and text we don't want
# https://github.com/rails/rails-html-sanitizer for more details
class HtmlScrubber < Rails::Html::PermitScrubber
  BASIC_TAGS    = 'p,br,strong,b,em,i,u,sub,sup,pre'.freeze
  EXTRA_TAGS    = ',a,div,span,code,ol,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td'.freeze
  STANDARD_TAGS = Set.new((BASIC_TAGS + EXTRA_TAGS).split(',')).freeze
  TAG_ATTRS     = Set.new(%w(href rel reversed start target title type style)).freeze

  def initialize(attrs = [])
    super()
    self.tags = STANDARD_TAGS
    self.attributes = TAG_ATTRS + attrs
  end

  def skip_node?(node)
    # this is a crappy hack to get around Microsoft deciding that adding
    # HTML style comments within style tags is a good idea
    node.children.remove if node.name == 'style'

    node.text?
  end

  def self.standalone_scrub!(value)
    scrubber = new
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end

  def self.style_scrub!(value)
    scrubber = new(['style'])
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end
end
