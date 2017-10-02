# CardContent represents any piece of user-configurable content
# that will be rendered into a card.  This includes things like
# questions (radio buttons, text input, selects), static informational
# text, or widgets (developer-created chunks of functionality with
# user-configured behavior)
class CardContent < ActiveRecord::Base
  include Attributable
  include XmlSerializable
  attr_writer :quick_children

  acts_as_nested_set

  belongs_to :card_version, inverse_of: :card_contents
  has_one :card, through: :card_version
  has_many :card_content_validations, dependent: :destroy
  validates :card_version, presence: true

  validates :parent_id,
            uniqueness: {
              scope: :card_version,
              message: "Card versions can only have one root node."
            },
            if: -> { root? }

  has_many :answers

  # -- Card Content Validations
  # Note that the checks present here work in concert with the xml validations
  # in the config/card.rnc file to assure that card content of a given type
  # is valid.  In the event that xml input stops being the only way to create
  # new card data, some of the work done by the xml schema will probably need
  # to be accounted for here.
  validate :content_value_type_combination
  validate :value_type_for_default_answer_value
  validate :default_answer_present_in_possible_values

  SUPPORTED_VALUE_TYPES = %w[attachment boolean question-set text html].freeze

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
      'export-paper': [nil],
      'field-set': [nil],
      'short-input': ['text'],
      'check-box': ['boolean'],
      'file-uploader': ['attachment'],
      'text': [nil],
      'paragraph-input': ['text', 'html'],
      'radio': ['boolean', 'text'],
      'tech-check': ['boolean'],
      'date-picker': ['text'],
      'sendback-reason': ['boolean'],
      'numbered-list': [nil],
      'mailer': [nil],
      'bulleted-list': [nil],
      'if': [nil],
      'plain-list': [nil] }.freeze.with_indifferent_access

  # Although we want to validate the various combinations of content types
  # and value types, many of the CardContent records that have been created
  # via the CardLoader don't have a content_type set at all, so we'll skip
  # validating those
  def content_value_type_combination
    return if content_type.blank?
    unless VALUE_TYPES_FOR_CONTENT.fetch(content_type, []).member?(value_type)
      errors.add(:content_type, "'#{content_type}' not valid with value_type '#{value_type}'")
    end
  end

  def value_type_for_default_answer_value
    if value_type.blank? && default_answer_value.present?
      errors.add(:base, "value type must be present in order to set a default answer value")
    end
  end

  def default_answer_present_in_possible_values
    return if default_answer_value.blank? || possible_values.blank?
    values = possible_values.map { |v| v['value'] }
    return if values.include? default_answer_value

    errors.add(:base, "default answer must be one of the following values: #{values}")
  end

  def render_tag(xml, attr_name, attr)
    safe_dump_text(xml, attr_name, attr) if attr.present?
  end

  # content_attrs rendered into the <card-content> tag itself
  def content_attrs
    {
      'ident' => ident,
      'content-type' => content_type,
      'value-type' => value_type,
      'child-tag' => child_tag,
      'custom-class' => custom_class,
      'custom-child-class' => custom_child_class,
      'wrapper-tag' => wrapper_tag,
      'visible-with-parent-answer' => visible_with_parent_answer,
      'default-answer-value' => default_answer_value
    }.merge(additional_content_attrs).compact
  end

  # rubocop:disable Metrics/MethodLength
  def additional_content_attrs
    case content_type
    when 'file-uploader'
      {
        'allow-multiple-uploads' => allow_multiple_uploads,
        'allow-file-captions' => allow_file_captions,
        'allow-annotations' => allow_annotations,
        'error-message' => error_message,
        'required-field' => required_field
      }
    when 'if'
      {
        'condition' => condition
      }
    when 'paragraph-input'
      {
        'editor-style' => editor_style,
        'allow-annotations' => allow_annotations,
        'required-field' => required_field
      }
    when 'short-input'
      {
        'allow-annotations' => allow_annotations,
        'required-field' => required_field
      }
    when 'radio', 'check-box', 'dropdown', 'tech-check'
      {
        'allow-annotations' => allow_annotations,
        'required-field' => required_field
      }
    when 'date-picker'
      {
        'required-field' => required_field
      }
    else
      {}
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def to_xml(options = {})
    setup_builder(options).tag!('content', content_attrs) do |xml|
      render_tag(xml, 'instruction-text', instruction_text)
      render_tag(xml, 'text', text)
      render_tag(xml, 'label', label)
      preload_descendants if @quick_children.nil?
      card_content_validations.each do |ccv|
        # Do not serialize the required-field validation, it is handled via the
        # "required-field" attribute.
        next if ccv.validation_type == 'required-field'
        create_card_config_validation(ccv, xml)
      end
      if possible_values.present?
        possible_values.each do |item|
          xml.tag!('possible-value', label: item['label'], value: item['value'])
        end
      end
      children.each { |child| child.to_xml(builder: xml, skip_instruct: true) }
    end
  end

  # rubocop:enable Metrics/AbcSize

  # recursively traverse nested card_contents
  def traverse(visitor)
    visitor.visit(self)
    children.each { |card_content| card_content.traverse(visitor) }
  end

  # Return the ids of the children. If quick_children has been set, use that,
  # otherwise use the children method of awesome nested set.
  def unsorted_child_ids
    @unsorted_child_ids ||= begin
                              if leaf?
                                []
                              elsif !@quick_children.nil?
                                @quick_children.map(&:id)
                              else
                                children.pluck(:id).uniq
                              end
                            end
  end

  # From this node, return a set of this node and its descendants, with the
  # `quick_children` attribute set to the children of each node. This can load
  # an entire traversable tree in one database query.
  # Returns an array of CardContent objects.
  def preload_descendants
    all = [self] + descendants.includes(:content_attributes, :card_content_validations).to_a
    children = all.group_by(&:parent_id)
    all.each do |d|
      d.quick_children = children.fetch(d.id, [])
    end
    all
  end

  # Return the @quick_children if set, otherwise return the children.
  def children
    return @quick_children unless @quick_children.nil?
    super
  end

  private

  def create_card_config_validation(ccv, xml)
    validation_attrs = { 'validation-type': ccv.validation_type }
                         .delete_if { |_k, v| v.nil? }
    xml.tag!('validation', validation_attrs) do
      xml.tag!('error-message', ccv.error_message)
      xml.tag!('validator', ccv.validator)
    end
  end
end
