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
    @xml = XmlCardDocument.new(xml_string)
    Card.transaction do
      card.card_versions << latest_card_version(replace: replace_latest_version)
    end
    card
  end

  private

  def latest_card_version(replace:)
    if replace
      # remove and decrement latest card_version
      card.latest_card_version.try(:destroy!)
      card.reload
      card.latest_version = card.latest_version.pred
    end

    build_card_version.tap do |card_version|
      card.latest_version = card_version.version
      card.save!
    end
  end

  def build_card_version
    card.card_versions.create(card_version_attributes).tap do |card_version|
      build_card_contents(card_version)
      root = card_version.content_root
      raise XmlCardDocument::XmlValidationError, root.errors if root.invalid?
    end
  end

  def build_card_contents(card_version)
    xml.contents.map do |content|
      build_card_content(card_version, content, parent: nil)
    end
  end

  def build_card_content(card_version, content, parent: nil)
    attributes = card_content_attributes(content, card_version)

    card_version.card_contents.new(attributes).tap do |root|
      root.parent = parent
      root.save!
      root.card_content_validations << build_card_content_validations(content)
      root.card_content_validations << maybe_build_required_field_validation(root)

      content.child_elements('content').each do |child|
        card_content = build_card_content(card_version, child, parent: root)
        card_content.save!
        root.card_contents << card_content
      end
    end
  end

  def build_card_content_validations(content)
    content.child_elements('validation').map do |validation|
      attributes = card_content_validation_attributes(validation)
      CardContentValidation.new(attributes)
    end
  end

  def maybe_build_required_field_validation(card_content)
    return [] unless card_content.required_field
    CardContentValidation.new(
      validation_type: "required-field",
      error_message: "This field is required.",
      validator: true
    )
  end

  def card_version_attributes
    {
      version: card.latest_version.to_i.next,
      required_for_submission: xml.card.attr_value('required-for-submission') == 'true',
      workflow_display_only: xml.card.attr_value('workflow-display-only') == 'true'
    }
  end

  def card_content_validation_attributes(content)
    {
      validator: content.tag_text('validator'),
      validation_type: content.attr_value('validation-type'),
      error_message: content.tag_text('error-message')
    }
  end

  # rubocop:disable MethodLength, AbcSize
  def card_content_attributes(content, card_version)
    {
      card_version: card_version,
      allow_file_captions: content.attr_value('allow-file-captions'),
      allow_multiple_uploads: content.attr_value('allow-multiple-uploads'),
      allow_annotations: content.attr_value('allow-annotations'),
      child_tag: content.attr_value('child-tag'),
      custom_class: content.attr_value('custom-class'),
      custom_child_class: content.attr_value('custom-child-class'),
      wrapper_tag: content.attr_value('wrapper-tag'),
      content_type: content.attr_value('content-type'),
      default_answer_value: content.attr_value('default-answer-value'),
      error_message: content.attr_value('error-message'),
      ident: content.attr_value('ident'),
      required_field: content.attr_value('required-field'),
      label: content.tag_text('label'),
      instruction_text: content.tag_text('instruction-text'),
      possible_values: content.fetch_values('possible-value', [:label, :value]),
      text: content.tag_text('text'),
      editor_style: content.attr_value('editor-style'),
      condition: content.attr_value('condition'),
      value_type: content.attr_value('value-type'),
      visible_with_parent_answer: content.attr_value('visible-with-parent-answer'),
      key: content.attr_value('key')
    }
  end
  # rubocop:enable MethodLength, AbcSize
end
