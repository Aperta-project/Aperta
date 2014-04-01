class Comment < ActiveRecord::Base

belongs_to :message_task, class_name: 'StandardTasks::MessageTask', inverse_of: :comments
belongs_to :commenter, class_name: 'User'

end
