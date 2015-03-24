module StandardTasks
  class Funder < ActiveRecord::Base
    belongs_to :task, foreign_key: :task_id
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors
  end
end
