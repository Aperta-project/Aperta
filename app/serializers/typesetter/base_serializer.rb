module Typesetter
  # Base serializer for export
  class BaseSerializer < ActiveModel::Serializer
    REMOVE_P = Loofah::Scrubber.new(direction: :bottom_up) do |node|
      if node.name != "p"
        Loofah::Scrubber::CONTINUE
      else
        node.before node.children
        node.remove
      end
    end

    EM2I = Loofah::Scrubber.new do |node|
      node.name = "i" if node.name == "em"
    end

    STRONG2B = Loofah::Scrubber.new do |node|
      node.name = "b" if node.name == "strong"
    end

    def without_p_tags(str)
      return nil if str.nil?
      Loofah.fragment(str).scrub!(REMOVE_P).to_s
    end

    def fix_strong_em_tags(str)
      return nil if str.nil?
      Loofah.fragment(str).scrub!(EM2I).scrub!(STRONG2B).to_s
    end

    def strip_tags(str)
      return nil if str.nil?
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
