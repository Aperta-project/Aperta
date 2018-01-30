class AuthorsTask < Task
  DEFAULT_TITLE = 'Authors'.freeze
  DEFAULT_ROLE_HINT = 'author'.freeze

  include MetadataTask

  has_many :authors, through: :paper
  has_many :group_authors, through: :paper

  validates_with AssociationValidator,
    association: :authors,
    fail: :set_completion_error,
    if: :completed?,
    before_each_validation: ->(_task, author) { author.validate_all = true }

  def active_model_serializer
    AuthorsTaskSerializer
  end

  private

  def set_completion_error
    errors.add(:completed, "Please fix validation errors above.")
  end
end
