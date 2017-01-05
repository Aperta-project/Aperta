class ReviewerReport < ActiveRecord::Base
  include NestedQuestionable
  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision
end
