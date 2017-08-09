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
      if FeatureFlag[:KEEP_APEX_HTML]
        str
      else
        Loofah.fragment(str).scrub!(TITLE_CLEAN).to_s
      end
    end

    def fix_strong_em_tags(str)
      return nil if str.nil?
      if FeatureFlag[:KEEP_APEX_HTML]
        str
      else
        Loofah.fragment(str).scrub!(EM2I).scrub!(STRONG2B).to_s
      end
    end

    def strip_tags(str)
      return nil if str.nil?
      if FeatureFlag[:KEEP_APEX_HTML]
        str
      else
        Loofah.fragment(str).text
      end
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
