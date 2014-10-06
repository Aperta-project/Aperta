class Participation < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task, inverse_of: :participations
  belongs_to :participant, class_name: 'User', inverse_of: :participations

  private

  def notifier_payload
    {}
  end
end
