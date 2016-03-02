class Author < ActiveRecord::Base
  include EventStream::Notifiable
  include NestedQuestionable

  CONTRIBUTIONS_QUESTION_IDENT = "author--contributions"

  acts_as_list

  belongs_to :paper
  has_one :list_item, as: :item, dependent: :destroy

  belongs_to :authors_task, class_name: "TahiStandardTasks::AuthorsTask", inverse_of: :authors
  delegate :completed?, to: :authors_task, prefix: :task, allow_nil: true

  validates :first_name, :last_name, :author_initial, :affiliation, :email, presence: true, if: :task_completed?
  validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
  validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?
  validates :paper, presence: true

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def self.contributions_question
    NestedQuestion.where(owner_id: nil, owner_type: name, ident: CONTRIBUTIONS_QUESTION_IDENT).first
  end

  # this is a hook for the nested_question_answers_policy to find its related
  # task (to know if the user is authorized to conduct a specific action).
  def task
    authors_task
  end

  def contributions
    contributions_question = self.class.contributions_question
    return [] unless contributions_question
    question_ids = self.class.contributions_question.children.map(&:id)
    nested_question_answers.where(nested_question_id: question_ids)
  end

end
