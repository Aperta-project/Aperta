class Participation < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task, inverse_of: :participations
  belongs_to :user, inverse_of: :participations

  validates :user, presence: true
end
