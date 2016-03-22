class NestedQuestion < ActiveRecord::Base
  SUPPORTED_VALUE_TYPES = %w(attachment boolean question-set text)
  VALUE_REQUIRED_FOR_TYPES = %w(boolean question-set text)

  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
  has_many :nested_question_answers, dependent: :destroy, inverse_of: :nested_question

  validates :ident, presence: true, uniqueness: true
  validates :owner_type, presence: true
  validates :value_type, presence: true, inclusion: { in: SUPPORTED_VALUE_TYPES }

  def self.lookup_owner_type(owner_type)
    case owner_type
    when /Task$/
      Task
    when "Author"
      Author
    when "GroupAuthor"
      GroupAuthor
    when "Funder"
      TahiStandardTasks::Funder
    when "ReviewerRecommendation"
      TahiStandardTasks::ReviewerRecommendation
    else
      raise "Don't know how to lookup owner_type: #{owner_type}"
    end
  end

  def self.update_all_exactly!(question_hashes)
    # This method runs on a scope and takes and a list of nested
    # property hashes. Each hash represents a single question, and
    # must have at least an `ident` field.
    #
    # ANY QUESTIONS IN SCOPE WITHOUT HASHES IN THIS LIST WILL BE
    # DESTROYED.
    #
    # Any questions with hashes but not in scope will be created.

    updated_idents = []

    # Refresh the living, welcome the newly born
    update_nested!(question_hashes, updated_idents)

    existing_idents = all.map(&:ident)
    for_deletion = existing_idents - updated_idents
    where(ident: for_deletion).destroy_all
  end

  def attachment?
    value_type == "attachment"
  end

  def self.update_nested!(question_hashes, idents)
    question_hashes.map do |hash|
      idents.append(hash[:ident])
      child_hashes = hash.delete(:children) || []
      children = update_nested!(child_hashes, idents)

      question = NestedQuestion.find_or_initialize_by(ident: hash[:ident])
      question.children = children
      question.update!(hash)
      question
    end
  end
  private_class_method :update_nested!
end
