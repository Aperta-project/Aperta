class Author < ActiveRecord::Base
  include EventStreamNotifier
  belongs_to :paper
  acts_as_list

  private

  def notifier_payload
    { paper_id: paper.id }
  end
end
