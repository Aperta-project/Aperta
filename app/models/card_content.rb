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
  validates :parent_id,
            uniqueness: {
              scope: :card_version,
              message: "Card versions can only have one root node."
            },
            if: -> { root? }

  has_many :answers

  validates :ident,
            uniqueness: {
              message: "CardContent idents must be unique"
            },
            if: -> { ident.present? }

  validate :content_value_type_combination

  SUPPORTED_VALUE_TYPES = %w(attachment boolean question-set text).freeze
  VALUE_TYPES_FOR_CONTENT =
    { 'display-children': [nil],
      'short-input': ['text'],
      'text': [nil],
      'paragraph-input': ['text'],
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

  def to_xml(options = {})
    setup_builder(options).tag!(
      'content',
      'content-type' => content_type,
      'text' => text
    ) do |xml|
      children.each do |child|
        child.to_xml(builder: xml, skip_instruct: true)
      end
    end
  end
end
