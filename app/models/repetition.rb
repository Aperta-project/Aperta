class Repetition < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :card_content, inverse_of: :repetitions
  belongs_to :task, inverse_of: :repetitions

  has_many :answers, inverse_of: :repetition

  validates :card_content, presence: true
  validates :task, presence: true
end
