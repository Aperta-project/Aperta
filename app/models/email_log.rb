class EmailLog < ActiveRecord::Base
  belongs_to :paper
  belongs_to :task
  belongs_to :journal
end
