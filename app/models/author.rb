class Author < ActiveRecord::Base
  include Answerable
  include EventStream::Notifiable
  include NestedQuestionable
  include Tokenable
  include CoAuthorConfirmable

  CONTRIBUTIONS_QUESTION_IDENT = "author--contributions".freeze
  CORRESPONDING_QUESTION_IDENT = "author--published_as_corresponding_author".freeze
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "author--government-employee".freeze

  has_one :author_list_item, as: :author, dependent: :destroy, autosave: true

  has_one :paper,
          through: :author_list_item,
          inverse_of: :authors

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
    answer_for(CORRESPONDING_QUESTION_IDENT).coerced_value
  end

  def self.contributions_content
    CardContent.find_by(
      ident: CONTRIBUTIONS_QUESTION_IDENT
    )
  end

  def contributions
    contributions_content = self.class.contributions_content
    return [] unless contributions_content
    content_ids = self.class.contributions_content.children.map(&:id)
    answers.where(card_content_id: content_ids)
  end
end
