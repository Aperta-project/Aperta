class Task < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = []

  belongs_to :assignee, class_name: 'User'
  belongs_to :phase

  delegate :task_manager, to: :phase
end
