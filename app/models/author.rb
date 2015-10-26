class Author < ActiveRecord::Base
  include EventStream::Notifiable
  include NestedQuestionable

  CONTRIBUTIONS_QUESTION_IDENT = "contributions"

  acts_as_list

  belongs_to :paper

  belongs_to :authors_task, class_name: "TahiStandardTasks::AuthorsTask", inverse_of: :authors
  delegate :completed?, to: :authors_task, prefix: :task, allow_nil: true

  validates :first_name, :last_name, :affiliation, :department, :title, :email, presence: true, if: :task_completed?
  validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
  validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?
  validates :paper, presence: true

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def self.contributions_question
    NestedQuestion.where(owner_id: nil, owner_type: name, ident: CONTRIBUTIONS_QUESTION_IDENT).first
  end

  def self.nested_questions
    questions = []

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "published_as_corresponding_author",
      value_type: "boolean",
      text: "This person will be listed as the corresponding author on the published article",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "deceased",
      value_type: "boolean",
      text: "This person is deceased",
      position: 2
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: name,
      ident: "contributions",
      value_type: "question-set",
      text: "Author Contributions",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "conceived_and_designed_experiments",
          value_type: "boolean",
          text: "Conceived and designed the experiments",
          position: 1
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "performed_the_experiments",
          value_type: "boolean",
          text: "Performed the experiments",
          position: 2
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "analyzed_data",
          value_type: "boolean",
          text: "Analyzed the data",
          position: 3
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "contributed_tools",
          value_type: "boolean",
          text: "Contributed reagents/materials/analysis tools",
          position: 4
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "contributed_writing",
          value_type: "boolean",
          text: "Contributed to the writing of the manuscript",
          position: 5
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: name,
          ident: "other",
          value_type: "text",
          text: "Other",
          position: 6
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
