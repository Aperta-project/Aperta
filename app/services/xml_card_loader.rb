# Class to load cards from an XML configuration format.
class XmlCardLoader
  class ParseException < StandardError; end

  # Used for making completely new cards via the xml card loader
  def self.from_xml_string(xml, journal)
    XmlCardLoader.new(parse(xml), journal).make_card
  end

  # Called from card.update_from_xml when the card is published
  def self.new_version_from_xml_string(xml, card)
    XmlCardLoader.new(parse(xml), card.journal).make_new_version(card, nil)
  end

  # Called from card.update_from_xml when the latest version is a draft
  def self.replace_draft_from_xml_string(xml, card)
    XmlCardLoader.new(parse(xml), card.journal).replace_latest_version(card)
  end

  def root
    @root ||= @doc.xpath('/card').first
  end

  # We use RelaxNG to validate the xml. The config/card.rng file
  # is automatically generated from the config/card.rnc file.
  # Instructions for how to do that are included there.
  def initialize(doc, journal)
    @doc = doc
    @journal = journal
    rng_file = Rails.root.join('config', 'card.rng')
    @schema = Nokogiri::XML::RelaxNG(File.open(rng_file))
    @schema.validate(@doc).each do |error|
      raise error
    end
  end

  # Make card makes a new card with a published version.
  def make_card
    Card.transaction do
      card = Card.new(
        journal: @journal,
        name: attr_val(root, 'name')
      )
      make_new_version(card, Time.current)
      card
    end
  end

  def make_new_version(card, published_at)
    new_version_no = if card.card_versions.count.zero?
                       1
                     else
                       card.latest_version + 1
                     end
    card.latest_version = new_version_no
    version = card.card_versions.new(
      version: new_version_no,
      card: card,
      published_at: published_at,
      required_for_submission:
        attr_val(root, 'required-for-submission') == 'true'
    )
    content_root = make_card_content(root.xpath('/card/content').first, version)
    version.card_contents << content_root
    version.save!
    card.touch

    version
  end

  # 'replaces' the latest version of the card by updating its attributes
  # and then replacing its card content.
  def replace_latest_version(card)
    version = card.latest_card_version
    version.update(
      required_for_submission:
        attr_val(root, 'required-for-submission') == 'true'
    )
    version.card_contents.destroy_all

    new_content_root = make_card_content(
      root.xpath('/card/content').first,
      version
    )
    version.card_contents << new_content_root
    version.save!
    card.touch

    version
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

  def tag_text(el, tag)
    el.xpath(tag).first.try(:text).try(:strip)
  end

  def make_card_content(el, card_version)
    text = tag_text(el, 'text')
    placeholder = tag_text(el, 'placeholder')
    label = tag_text(el, 'label')
    content = CardContent.new(
      allow_multiple_uploads: attr_val(el, 'allow-multiple-uploads'),
      allow_file_captions: attr_val(el, 'allow-file-captions'),
      card_version: card_version,
      content_type: attr_val(el, 'content-type'),
      default_answer_value: attr_val(el, 'default-answer-value'),
      ident: attr_val(el, 'ident'),
      label: label,
      placeholder: placeholder,
      possible_values: parse_possible_values(el),
      text: text,
      value_type: attr_val(el, 'value-type'),
      visible_with_parent_answer: attr_val(el, 'visible-with-parent-answer')
    )
    el.xpath('content').each do |el1|
      content.children << make_card_content(el1, card_version)
    end
    content
  end
end
