class Participation < ActiveRecord::Base
  include EventStreamNotifier
  self.primary_key = :id

  belongs_to :task, inverse_of: :participations
  belongs_to :participant, class_name: 'User', inverse_of: :participations

  validates :participant_id, presence: true
end
