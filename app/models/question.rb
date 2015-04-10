class Question < ActiveRecord::Base
  belongs_to :task, inverse_of: :questions
  has_one :question_attachment, dependent: :destroy

  validates :ident, presence: true

  after_destroy { |question| question.task.touch }

end
