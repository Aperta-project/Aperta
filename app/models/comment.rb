class Comment < ActiveRecord::Base

belongs_to :message_task, inverse_of: :comments
belongs_to :commenter, class_name: 'User'

end
