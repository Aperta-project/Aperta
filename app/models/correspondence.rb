class Correspondence < ActiveRecord::Base
  self.table_name = "email_logs"

  belongs_to :paper
  belongs_to :task
  belongs_to :journal
end
