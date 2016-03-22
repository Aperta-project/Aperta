module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, foreign_key: "task_id", dependent: :destroy, inverse_of: :task
    has_many :comment_looks, through: :comments
  end
end
