# This class is responsible for taking an XML string that describes
# a Card instance and applying it to the Card.  This is used by an
# admin interface to create and update existing Cards.  Eventually,
# we expect this functionality to be replaced by gui admin screens.
class XmlCardLoader
  # called from card.update_from_xml when the card is published
  def self.new_version_from_xml_string(xml, card)
    new(card).load(xml, replace_latest_version: false)
  end

  # called from card.update_from_xml when the latest version is a draft
  def self.replace_draft_from_xml_string(xml, card)
    new(card).load(xml, replace_latest_version: true)
  end

  attr_accessor :xml, :card

  def initialize(card)
    @card = card
  end

  def load(xml_string, replace_latest_version: false)
    @xml = xml_card_document(xml_string)

    Card.transaction do
      card.card_versions << latest_card_version(replace: replace_latest_version)
      card.save!
    end
  end

  private

  def xml_card_document(xml)
    XmlCardDocument.new(xml)
  end

  def latest_card_version(replace:)
    if replace
      # remove and decrement latest card_version
      card.latest_card_version.try(&:destroy_fully!)
      card.latest_version = card.latest_version.pred
    end

    build_card_version.tap do |card_version|
      card.latest_version = card_version.version
    end
  end

  def build_card_version
    CardVersion.new(card_version_attributes).tap do |card_version|
      card_version.card_contents << build_card_contents(card_version)
    end
  end

  def build_card_contents(card_version)
    xml.contents.map do |content|
      build_card_content(content, card_version)
    end
  end

  def build_card_content_validations(content)
    content.child_elements('validation').map do |validation|
      attributes = card_content_validation_attributes(validation)
      CardContentValidation.new(attributes)
    end
  end

  def build_card_content(content, card_version)
    attributes = card_content_attributes(content, card_version)
    CardContent.new(attributes).tap do |root|
      # assign any validations
      root.card_content_validations << build_card_content_validations(content)

      # recursively create any nested child content
      content.child_elements('content').each do |child|
        root.children << build_card_content(child, card_version)
      end
    end
  end

  def card_version_attributes
    {
      version:
        card.latest_version.to_i.next,
      required_for_submission:
        xml.card.attr_value('required-for-submission') == 'true',
      workflow_display_only:
        xml.card.attr_value('workflow-display-only') == 'true'
    }
  end

  def card_content_validation_attributes(content)
    {
      validator:
        content.tag_text('validator'),
      validation_type:
        content.attr_value('validation-type'),
      error_message:
        content.tag_text('error-message')
    }
  end

  # rubocop:disable MethodLength
  def card_content_attributes(content, card_version)
    {
      card_version:
        card_version,
      allow_file_captions:
        content.attr_value('allow-file-captions'),
      allow_multiple_uploads:
        content.attr_value('allow-multiple-uploads'),
      allow_annotations:
        content.attr_value('allow-annotations'),
      content_type:
        content.attr_value('content-type'),
      default_answer_value:
        content.attr_value('default-answer-value'),
      ident:
        content.attr_value('ident'),
      label:
        content.tag_text('label'),
      instruction_text:
        content.tag_text('instruction-text'),
      possible_values:
        content.fetch_values('possible-value', [:label, :value]),
      text:
        content.tag_text('text'),
      editor_style: content.attr_value('editor-style'),
      value_type:
        content.attr_value('value-type'),
      visible_with_parent_answer:
        content.attr_value('visible-with-parent-answer')
    }
  end
  # rubocop:enable MethodLength
end
