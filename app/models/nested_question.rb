class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
  has_many :nested_question_answers

  def answer(value, **attrs)
    self.nested_question_answers.build({value:value, value_type:value_type}.reverse_merge(attrs))
  end

  def self.get_answer ident, owner
    question = NestedQuestion.where(ident: ident).first
    answer = NestedQuestionAnswer.where(nested_question_id: question.id, owner_id: owner.id).first

    if answer
      answer.value
    end
  end

  def self.set_answer ident, owner, value, current_answers
    question = NestedQuestion.where(ident: ident).first
    NestedQuestionAnswer.where(nested_question_id: question.id, owner_id: owner.id).destroy_all

    if value
      current_answers << question.answer(value, owner: owner)
    end
  end
end
