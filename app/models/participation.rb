class Participation < ActiveRecord::Base
  belongs_to :task, inverse_of: :participations
  belongs_to :participant, class_name: 'User', inverse_of: :participations
end
