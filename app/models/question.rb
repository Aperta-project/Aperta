class Question < ActiveRecord::Base
  belongs_to :task
  has_one :question_attachment, dependent: :destroy

  validates :ident, presence: true
end
