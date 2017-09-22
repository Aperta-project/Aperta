# This class is responsible for taking an XML string that describes
# a Card instance and applying it to the Card.  This is used by an
# admin interface to create and update existing Cards.  Eventually,
# we expect this functionality to be replaced by gui admin screens.
class XmlCardLoader
  attr_accessor :xml, :card

  def initialize(card)
    @card = card
  end

  def load(xml_string, replace_latest_version: false)
    @xml = XmlCardDocument.new(xml_string)
    card.card_versions << latest_card_version(replace: replace_latest_version)
    card
  end

  private

  def latest_card_version(replace:)
    if replace
      # remove and decrement latest card_version
      card.latest_card_version.try(:destroy!)
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

  def maybe_build_required_field_validation(card_content)
    return [] unless card_content.required_field
    CardContentValidation.new(
      validation_type: "required-field",
      error_message: "This field is required.",
      validator: true
    )
  end

  def omissible?(name, value)
    case Attributable::ATTRIBUTE_TYPES[name.to_s]
    when :json then value.blank?
    else value.nil?
    end
  end

  def build_card_content(content, card_version)
    attributes = card_content_attributes(content, card_version)
    content_type = content.attr_value('content-type')
    allowed_attributes = Attributable::CUSTOM_ATTRIBUTES[content_type]
    allowed_attributes += CardContent.attribute_names.map(&:to_sym) + [:card_version]
    attributes = attributes.delete_if { |key, value| omissible?(key, value) && !allowed_attributes.member?(key) }

    CardContent.new(attributes).tap do |root|
      # assign any validations
      root.card_content_validations << build_card_content_validations(content)
      root.card_content_validations << maybe_build_required_field_validation(root)
      # recursively create any nested child content
      content.child_elements('content').each do |child|
        root.card_contents << build_card_content(child, card_version)
        child.parent = content
      end
      raise XmlCardDocument::XmlValidationError, root.errors if root.invalid?
    end
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

  def card_content_attributes(content, card_version)
    names  = Attributable::ATTRIBUTE_NAMES
    dashed = Attributable::DASHED_NAMES

    attrs  = {card_version: card_version}
    names.each_with_object(attrs) do |name, hash|
      value = content.attr_value(dashed[name])
      hash[name] = value unless value.blank?
    end
  end
end
