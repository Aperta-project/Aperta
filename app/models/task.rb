class Task < ActiveRecord::Base
  belongs_to :assignee, class_name: 'User'
  belongs_to :phase
end
