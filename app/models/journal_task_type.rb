class JournalTaskType < ActiveRecord::Base
  belongs_to :journal, inverse_of: :journal_task_types

  validates :role, :title, presence: true
end
