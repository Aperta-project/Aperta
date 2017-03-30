# Class to load cards from an XML configuration format.
class XmlCardLoader
  class ParseException < StandardError; end

  def self.from_xml_string(xml, journal)
    XmlCardLoader.new(parse(xml), journal).make_card
  end

  def self.version_from_xml_string(xml, card)
    XmlCardLoader.new(parse(xml), card.journal).make_version(card)
  end

  def root
    @root ||= @doc.xpath('/card').first
  end

  def initialize(doc, journal)
    @doc = doc
    @journal = journal
    rng_file = Rails.root.join('config', 'card.rng')
    @schema = Nokogiri::XML::RelaxNG(File.open(rng_file))
    @schema.validate(@doc).each do |error|
      raise error
    end
  end

  def make_card
    Card.transaction do
      card = Card.new(
        journal: @journal,
        name: attr_val(root, 'name')
      )
      make_version(card)
      card
    end
  end

  def make_version(card)
    new_version = if card.card_versions.count.zero?
                    1
                  else
                    card.latest_version + 1
                  end
    card.latest_version = new_version
    version = card.card_versions.new(
      version: new_version,
      card: card
    )
    content_root = make_card_content(
      root.xpath('/card/content').first,
      version
    )
    version.card_contents << content_root
  end

  def self.parse(xml_string)
    Nokogiri::XML.parse(xml_string)
  end
  private_class_method :parse

  private

  def attr_val(el, name)
    el.attributes[name].try(:value)
  end

  def parse_possible_values(el)
    el.xpath('possible-value').map do |el1|
      {
        label: attr_val(el1, 'label'),
        value: attr_val(el1, 'value')
      }
    end
  end

  def make_card_content(el, card_version)
    text = el.xpath('text').first.try(:text).try(:strip) || attr_val(el, 'text')
    content = CardContent.new(
      ident: attr_val(el, 'ident'),
      value_type: attr_val(el, 'value-type'),
      content_type: attr_val(el, 'content-type'),
      text: text,
      possible_values: parse_possible_values(el),
      card_version: card_version
    )
    el.xpath('content').each do |el1|
      content.children << make_card_content(el1, card_version)
    end
    content
  end
end
