# This class is responsible for validating, loading, and parsing a
# Card XML string.
class XmlCardDocument
  attr_reader :raw, :doc

  SCHEMA_FILE = Rails.root.join('config', 'card.rng').freeze
  CARD_XPATH = "/card".freeze
  CONTENT_XPATH = "/card/content".freeze

  def initialize(xml_string)
    @raw = xml_string
    @doc = parse(xml_string)
  end

  def validate!
    schema.validate(doc).each do |error|
      raise error
    end
  end

  def card
    @card ||= begin
      el = doc.xpath(CARD_XPATH).first
      XmlElementDataExtractor.new(el)
    end
  end

  def contents
    @content ||= begin
      els = doc.xpath(CONTENT_XPATH)
      els.map { |el| XmlElementDataExtractor.new(el) }
    end
  end

  private

  def parse(xml_string)
    Nokogiri::XML.parse(xml_string)
  end

  def schema
    @schema ||= Nokogiri::XML::RelaxNG(File.open(SCHEMA_FILE))
  end
end
