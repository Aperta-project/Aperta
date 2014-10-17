class Author < ActiveRecord::Base
  include EventStreamNotifier

  actable
  acts_as_list

  belongs_to :paper

  def self.generic
    where(actable_id: nil, actable_type: nil)
  end

  private

  def notifier_payload
    { paper_id: paper.id }
  end
end
