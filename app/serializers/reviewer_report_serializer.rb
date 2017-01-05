class ReviewerReportSerializer < ActiveModel::Serializer
  attributes :id,
             :decision_id,
             :user_id
  has_one :task
end