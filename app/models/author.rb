class Author < ActiveRecord::Base
  include EventStream::Notifiable
  include NestedQuestionable

  CONTRIBUTIONS_QUESTION_IDENT = "author--contributions"
  CORRESPONDING_QUESTION_IDENT = "author--published_as_corresponding_author"
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "author--government-employee"

  has_one :author_list_item, as: :author, dependent: :destroy, autosave: true

  has_one :paper,
          through: :author_list_item,
          inverse_of: :authors

  include PgSearch
  pg_search_scope \
    :fuzzy_search,
    against: [:first_name, :last_name, :email],
    associated_against: { user: :username },
    ignoring: :accents,
    using: { tsearch: { prefix: true }, trigram: { threshold: 0.3 } }

  # Not validated as not all authors have corresponding users.
  belongs_to :user

  delegate :position, to: :author_list_item

  validates :first_name, :last_name, :author_initial, :affiliation, :email, presence: true, if: :task_completed?
  validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
  validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?

  def full_name
    "#{first_name} #{last_name}"
  end

  def paper_id
    ensured_author_list_item.paper_id
  end

  def paper_id=(paper_id)
    ensured_author_list_item.paper_id = paper_id
  end

  def position=(position)
    ensured_author_list_item.position = position
  end

  def ensured_author_list_item
    author_list_item || build_author_list_item
  end

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def task_completed?
    task && task.completed
  end

  def task
    Task.find_by(paper_id: paper_id, type: TahiStandardTasks::AuthorsTask.name)
  end

  def corresponding?
    return false unless answer_for(CORRESPONDING_QUESTION_IDENT)
    answer_for(CORRESPONDING_QUESTION_IDENT).value
  end

  def self.contributions_question
    NestedQuestion.find_by(
      owner_id: nil,
      owner_type: name,
      ident: CONTRIBUTIONS_QUESTION_IDENT)
  end

  def contributions
    contributions_question = self.class.contributions_question
    return [] unless contributions_question
    question_ids = self.class.contributions_question.children.map(&:id)
    nested_question_answers.where(nested_question_id: question_ids)
  end
end
