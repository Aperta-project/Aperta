# CardContent represents any piece of user-configurable content
# that will be rendered into a card.  This includes things like
# questions (radio buttons, text input, selects), static informational
# text, or widgets (developer-created chunks of functionality with
# user-configured behavior)
class CardContent < ActiveRecord::Base
  include XmlSerializable

  acts_as_nested_set
  acts_as_paranoid

  belongs_to :card_version
  has_one :card, through: :card_version

  validates :card_version, presence: true

  # since we use acts_as_paranoid we need to take into account whether a given
  # piece of card content has been deleted for uniqueness checks on parent_id
  # and ident
  validates :parent_id,
            uniqueness: {
              scope: :card_version,
              message: "Card versions can only have one root node."
            },
            if: -> { root? }

  has_many :answers

  validates :ident,
            uniqueness: {
              scope: :deleted_at,
              message: "CardContent idents must be unique"
            },
            if: -> { ident.present? }

  # -- Card Content Validations
  # Note that the checks present here work in concert with the xml validations
  # in the config/card.rnc file to assure that card content of a given type
  # is valid.  In the event that xml input stops being the only way to create
  # new card data, some of the work done by the xml schema will probably need
  # to be accounted for here.
  validate :content_value_type_combination
  validate :value_type_for_default_answer_value
  validate :default_answer_present_in_possible_values

  SUPPORTED_VALUE_TYPES = %w(attachment boolean question-set text html).freeze

  # Note that value_type really refers to the value_type of answers associated
  # with this piece of card content. In the old NestedQuestion world, both
  # NestedQuestionAnswer and NestedQuestion had a value_type column, and the
  # value_type was duplicated between them. In the hash below, we say that the
  # 'short-input' answers will have a 'text' value type, while 'radio' answers
  # can either be boolean or text.  The 'text' content_type is really static
  # text, which will never have an answer associated with it, hence it has no
  # possible value types.  The same goes for the other container types
  # (field-set, etc)
  VALUE_TYPES_FOR_CONTENT =
    { 'display-children': [nil],
      'display-with-value': [nil],
      'dropdown': ['text', 'boolean'],
      'field-set': [nil],
      'short-input': ['text'],
      'check-box': ['boolean'],
      'file-uploader': ['attachment'],
      'text': [nil],
      'paragraph-input': ['text', 'html'],
      'radio': ['boolean', 'text'] }.freeze.with_indifferent_access

  # Although we want to validate the various combinations of content types
  # and value types, many of the CardContent records that have been created
  # via the CardLoader don't have a content_type set at all, so we'll skip
  # validating those
  def content_value_type_combination
    return if content_type.blank?
    unless VALUE_TYPES_FOR_CONTENT.fetch(content_type, []).member?(value_type)
      errors.add(
        :content_type,
        "'#{content_type}' not valid with value_type '#{value_type}'"
      )
    end
  end

  def value_type_for_default_answer_value
    if value_type.blank? && default_answer_value.present?
      errors.add(
        :default_answer_value,
        "value type must be present in order to set a default answer value"
      )
    end
  end

  def default_answer_present_in_possible_values
    return if default_answer_value.blank? || possible_values.blank?

    vals = possible_values.map { |v| v["value"] }
    unless vals.include? default_answer_value
      errors.add(
        :default_answer_value,
        "must be one of the following values: #{vals}"
      )
    end
  end

  # Note that we essentially copied this method over from nested question
  def self.update_all_exactly!(content_hashes)
    # This method runs on a scope and takes and a list of nested property
    # hashes. Each hash represents a single piece of card content, and must
    # have at least an `ident` field.
    #
    # ANY CONTENT IN SCOPE WITHOUT HASHES IN THIS LIST WILL BE DESTROYED.
    #
    # Any content with hashes but not in scope will be created.

    updated_idents = []

    # Refresh the living, welcome the newly born
    update_nested!(content_hashes, nil, updated_idents)

    existing_idents = all.map(&:ident)
    for_deletion = existing_idents - updated_idents
    raise "You forgot some questions: #{for_deletion}" \
      unless for_deletion.empty?
  end

  def self.update_nested!(content_hashes, parent_id, idents)
    content_hashes.map do |hash|
      idents.append(hash[:ident])
      child_hashes = hash.delete(:children) || []
      content = CardContent.find_or_initialize_by(ident: hash[:ident])
      content.parent_id = parent_id
      content.update!(hash)
      update_nested!(child_hashes, content.id, idents)
      content
    end
  end

  def render_tag(xml, attr_name, attr)
    safe_dump_text(xml, attr_name, attr) if attr.present?
  end

  def content_attrs
    {
      'content-type' => content_type,
      'value-type' => value_type,
      'visible-with-parent-answer' => visible_with_parent_answer,
      'default-answer-value' => default_answer_value,
      'allow-multiple-uploads' => allow_multiple_uploads,
      'allow-file-captions' => allow_file_captions
    }.compact
  end

  def to_xml(options = {})
    setup_builder(options).tag!('content', content_attrs) do |xml|
      render_tag(xml, 'placeholder', placeholder)
      render_tag(xml, 'text', text)
      render_tag(xml, 'label', label)
      if possible_values.present?
        possible_values.each do |item|
          xml.tag!('possible-value', label: item['label'], value: item['value'])
        end
      end
      children.each do |child|
        child.to_xml(builder: xml, skip_instruct: true)
      end
    end
  end
end
