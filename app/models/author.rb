class Author < ActiveRecord::Base
  include EventStreamNotifier

  actable
  acts_as_list

  belongs_to :paper

  private

  def notifier_payload
    { paper_id: paper.id }
  end
end
