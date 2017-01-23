class ReviewerReport < ActiveRecord::Base
  include NestedQuestionable
  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision

  validates :task, uniqueness: { scope: [:task_id, :user_id, :decision_id],
    message: 'Only one report allowed per reviewer per decision' }
end
