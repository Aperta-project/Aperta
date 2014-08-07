class JournalTaskType < ActiveRecord::Base
  belongs_to :task_type, inverse_of: :journal_task_types
  belongs_to :journal, inverse_of: :journal_task_types
end
