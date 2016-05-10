# Authors that are not individual people; they are in the
# same list as authors, but have different data.
class GroupAuthor < ActiveRecord::Base
  include EventStream::Notifiable
  include NestedQuestionable

  CONTRIBUTIONS_QUESTION_IDENT = "group-author--contributions"
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "group-author--government-employee"

  has_one :author_list_item, as: :author, dependent: :destroy, autosave: true

  has_one :paper,
          through: :author_list_item,
          inverse_of: :authors
  delegate :position, to: :author_list_item

  validates :contact_first_name,
            :contact_last_name,
            :contact_email,
            :name,
            presence: true,
            if: :task_completed?
  validates :contact_email,
            format: { with: Devise.email_regexp,
                      message: "needs to be a valid email address" },
            if: :task_completed?
  validates :contributions,
            presence: { message: "one must be selected" },
            if: :task_completed?

  def paper_id
    ensured_author_list_item.paper_id
  end

  def paper_id=(paper_id)
    ensured_author_list_item.paper_id = paper_id
  end

  def task_completed?
    task && task.completed
  end

  def task
    Task.find_by(paper_id: paper_id, type: TahiStandardTasks::AuthorsTask.name)
  end

  def position=(position)
    ensured_author_list_item.position = position
  end

  def ensured_author_list_item
    author_list_item || build_author_list_item
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
