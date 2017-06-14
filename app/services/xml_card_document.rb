require "jing"
require 'tempfile'

# This class is responsible for validating, loading, and parsing a
# Card XML string.
class XmlCardDocument
  attr_reader :raw, :doc

  SCHEMA_FILE = Rails.root.join('config', 'card.rng').freeze
  CARD_XPATH = "/card".freeze
  CONTENT_XPATH = "/card/content".freeze

  # custom exception class wraps list of errors, each with positional info
  class XmlValidationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = []
      errors.each do |error|
        @errors << {
          message: error[:message],
          line: error[:line],
          col: error[:column]
        }
      end
    end

    def message
      errors
    end
  end

  def initialize(xml_string)
    @raw = xml_string
    validate!
    @doc = parse(@raw)
  end

  def validate!
    # create a temp file for xml content (required by Jing validator API)
    temproot = Rails.root.join('tmp').to_s
    tempfile = Tempfile.new('card_xml', temproot)
    tempfile.write(@raw)
    tempfile.close

    errors = schema.validate(tempfile.path)
    raise(XmlValidationError, errors) unless errors.empty?
  ensure
    tempfile.unlink
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
    @schema ||= Jing.new(SCHEMA_FILE.to_s)
  end
end
