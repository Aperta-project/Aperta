class EventStore < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  validates :name, :timestamp, :journal_id, :paper_id, :record_id, :record_type, presence: true

end
