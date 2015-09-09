module PlosAuthors
  class PlosAuthor < ActiveRecord::Base
    include EventStream::Notifiable
    include MetadataTask

    acts_as :author, dependent: :destroy
    delegate :completed?, to: :plos_authors_task, prefix: :task, allow_nil: true

    belongs_to :plos_authors_task, inverse_of: :plos_authors
    has_many :nested_question_answers, as: :owner
    has_many :nested_questions, through: :nested_question_answers

    validates :first_name, :last_name, :affiliation, :department, :title, :email, presence: true, if: :task_completed?
    validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
    validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?
    validates :paper, presence: true

    def self.for_paper(paper)
      where(paper_id: paper)
    end

    def event_stream_serializer(user: nil)
      PlosAuthorsSerializer.new(plos_authors_task.plos_authors, root: :plos_authors)
    end

    def corresponding=(value)
      NestedQuestion.set_answer "corresponding", self, value, self.nested_question_answers
    end

    def corresponding
      NestedQuestion.get_answer "corresponding", self
    end

    def deceased=(value)
      NestedQuestion.set_answer "deceased", self, value, self.nested_question_answers
    end

    def deceased
      NestedQuestion.get_answer "deceased", self
    end

    def contributions=(nested_question_ids)
      nested_question_ids ||= []
      nested_question_answers.destroy_all

      nested_question_ids = arr.map{ |hsh| hsh["id"] }.uniq
      updated_questions = NestedQuestion.where(id:nested_question_ids).all

      updated_questions.each do |question|
        self.nested_question_answers << question.answer(true, owner:self)
      end
    end

    def contributions
      nested_question_answers.all.map(&:nested_question_id)
    end

    def contributions_text
      association(:nested_questions).reader.includes(:nested_question_answers).map do |question|
        question.text
      end
    end

    def nested_questions_and_answers
      answers = []
      self.plos_authors_task.nested_questions.each do |question|
        if question.parent_id == nil
          answers.push(answer_question question)
        end
      end
      answers
    end

    def answer_question question
      children = []
      question.children.each do |nested_question|
        children.push answer_question(nested_question)
      end
      return { text: question.text, id: question.id, ident: question.ident, value_type: question.value_type, answer: NestedQuestion.get_answer(question.ident, self), children: children}
    end
  end
end
