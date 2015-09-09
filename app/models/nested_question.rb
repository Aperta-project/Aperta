class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
  has_many :nested_question_answers

  def answer(value, **attrs)
    self.nested_question_answers.build({value:value, value_type:value_type}.reverse_merge(attrs))
  end
end
