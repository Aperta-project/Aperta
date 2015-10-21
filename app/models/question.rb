class Question < ActiveRecord::Base
  belongs_to :task
  belongs_to :decision
  has_one :question_attachment, dependent: :destroy, as: :question

  validates :ident, presence: true
end
