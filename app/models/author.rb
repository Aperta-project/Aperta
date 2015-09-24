class Author < ActiveRecord::Base
  include EventStream::Notifiable

  acts_as_list

  belongs_to :paper

  belongs_to :authors_task, class_name: "TahiStandardTasks::AuthorsTask", inverse_of: :authors
  delegate :completed?, to: :authors_task, prefix: :task, allow_nil: true

  has_many :nested_question_answers, as: :owner, dependent: :destroy

  serialize :contributions, Array

  validates :first_name, :last_name, :affiliation, :department, :title, :email, presence: true, if: :task_completed?
  validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
  validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?
  validates :paper, presence: true

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def self.nested_questions
    questions = []

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "published_as_corresponding_author",
      value_type: "boolean",
      text: "This person will be listed as the corresponding author on the published article"
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "deceased",
      value_type: "boolean",
      text: "This person is deceased"
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "contributions",
      value_type: "question-set",
      text: "Author Contributions",
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "conceived_and_designed_experiments",
          value_type: "boolean",
          text: "Conceived and designed the experiments"
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "performed_the_experiments",
          value_type: "boolean",
          text: "Performed the experiments"
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "analyzed_data",
          value_type: "boolean",
          text: "Analyzed the data"
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "contributed_tools",
          value_type: "boolean",
          text: "Contributed reagents/materials/analysis tools"
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "contributed_writing",
          value_type: "boolean",
          text: "Contributed to the writing of the manuscript"
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "other",
          value_type: "text",
          text: "Other"
        )
      ]
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
        q.save!
      end
    end

    NestedQuestion.where(owner_id:nil, owner_type:name).all
  end

  def nested_questions
    self.class.nested_questions
  end
end
