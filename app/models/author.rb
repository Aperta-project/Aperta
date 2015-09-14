class Author < ActiveRecord::Base
  include EventStream::Notifiable

  acts_as_list

  belongs_to :paper
  belongs_to :authors_task, inverse_of: :authors
  delegate :completed?, to: :authors_task, prefix: :task, allow_nil: true

  serialize :contributions, Array

  validates :first_name, :last_name, :affiliation, :department, :title, :email, presence: true, if: :task_completed?
  validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
  validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?
  validates :paper, presence: true

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def event_stream_serializer(user: nil)
    AuthorsSerializer.new(paper.authors, root: :authors)
  end
end
