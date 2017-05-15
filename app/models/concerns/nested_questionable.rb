module NestedQuestionable
  extend ActiveSupport::Concern

  class_methods do
    def nested_questions
      NestedQuestion.where(owner_id: nil, owner_type: name)
    end
  end

  included do
    has_many :nested_question_answers, as: :owner, dependent: :destroy
  end

  def nested_questions
    self.class.nested_questions
  end
end
