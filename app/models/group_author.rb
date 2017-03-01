# Authors that are not individual people; they are in the
# same list as authors, but have different data.
class GroupAuthor < ActiveRecord::Base
  include Answerable
  include EventStream::Notifiable
  include NestedQuestionable
  include Tokenable
  include CoAuthorConfirmable

  CONTRIBUTIONS_QUESTION_IDENT = "group-author--contributions".freeze
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "group-author--government-employee".freeze

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

  alias_attribute :email, :contact_email
  alias_attribute :full_name, :name

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

  def self.contributions_content
    CardContent.find_by(ident: CONTRIBUTIONS_QUESTION_IDENT)
  end

  def contributions
    contributions_content = self.class.contributions_content
    return [] unless contributions_content
    content_ids = self.class.contributions_content.children.map(&:id)
    answers.where(card_content_id: content_ids)
  end
end
