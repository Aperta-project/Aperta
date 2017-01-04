class ReviewerReport < ActiveRecord::Base
  include NestedQuestionable
  belongs_to :task
  belongs_to :user
  belongs_to :decision
end
