class Author < ActiveRecord::Base
  include EventStreamNotifier
  belongs_to :paper
  acts_as_list


  def set_position=(position)
    set_list_position(position) if position.present?
  end

  private

  def notifier_payload
    { paper_id: paper.id }
  end
end
