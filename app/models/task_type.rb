class TaskType < ActiveRecord::Base
  has_many :journal_task_types, inverse_of: :task_type
end
