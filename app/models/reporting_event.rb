class ReportingEvent < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  validates :name, :trigger_name, :journal_id, :kind, :paper_id, :record_id, :record_type, :timestamp, presence: true

end
