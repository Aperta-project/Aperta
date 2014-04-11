class Comment < ActiveRecord::Base
  belongs_to :message_task, inverse_of: :comments, foreign_key: :task_id
  belongs_to :commenter, class_name: 'User'
end
