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

    if replace_latest_version
      card.latest_card_version.try(:destroy!)
      card.latest_version = card.latest_version.pred
    end

    build_card_version.tap do |card_version|
      card.latest_version = card_version.version
    end
  end

  private

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
    attributes = card_content_attributes(content)
    content_type = content.attr_value('content-type')
    puts "Content type: #{content_type}"
    allowed_attributes = Attributable::CUSTOM_ATTRIBUTES[content_type]
    allowed_attributes += CardContent.attribute_names.map(&:to_sym)
    attributes = attributes.delete_if { |key, value| omissible?(key, value) && !allowed_attributes.member?(key) }

    card_version.card_contents.new(attributes).tap do |root|
      root.parent = parent
      root.card_content_validations << build_card_content_validations(content)
      root.card_content_validations << maybe_build_required_field_validation(root)
      root.save!

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

  def omissible?(name, value)
    case Attributable::ATTRIBUTE_TYPES[name.to_s]
    when :json then value.blank?
    else value.nil?
    end
  end

  def card_content_attributes(content)
    names  = Attributable::ATTRIBUTE_NAMES
    dashed = Attributable::DASHED_NAMES
    names.each_with_object({}) do |name, hash|
      value = content.attr_value(dashed[name])
      hash[name] = value unless omissible?(name, value)
    end
  end
end
