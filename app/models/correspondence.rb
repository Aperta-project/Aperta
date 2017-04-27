class Correspondence < ActiveRecord::Base
  self.table_name = "email_logs"

  belongs_to :paper
  belongs_to :task
  belongs_to :journal

  def materialized_mail
    Mail.new(raw_source)
  end
end
