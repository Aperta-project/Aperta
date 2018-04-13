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

module Typesetter
  # Base serializer for export
  class BaseSerializer < ActiveModel::Serializer
    def self.make_stripper(*elements)
      Loofah::Scrubber.new(direction: :bottom_up) do |node|
        if !elements.member?(node.name)
          Loofah::Scrubber::CONTINUE
        else
          node.before node.children
          node.remove
        end
      end
    end

    TITLE_CLEAN = make_stripper("p", "span", "pre", "u")

    EM2I = Loofah::Scrubber.new do |node|
      node.name = "i" if node.name == "em"
    end

    STRONG2B = Loofah::Scrubber.new do |node|
      node.name = "b" if node.name == "strong"
    end

    def title_clean(str)
      return nil if str.nil?
      return str if FeatureFlag[:KEEP_APEX_HTML]
      Loofah.fragment(str).scrub!(TITLE_CLEAN).to_s
    end

    def fix_strong_em_tags(str)
      return nil if str.nil?
      return str if FeatureFlag[:KEEP_APEX_HTML]
      Loofah.fragment(str).scrub!(EM2I).scrub!(STRONG2B).to_s
    end

    def strip_tags(str)
      return nil if str.nil?
      return str if FeatureFlag[:KEEP_APEX_HTML]
      Loofah.fragment(str).text
    end

    def attributes
      hash = super
      hash.each do |k, v|
        hash[k] = fix_strong_em_tags(v) if v.is_a? String
      end
      hash
    end
  end
end
