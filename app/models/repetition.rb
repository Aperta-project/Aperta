class Repetition < ActiveRecord::Base
  has_closure_tree order: :position
  acts_as_list scope: [:card_content_id, :task_id, :parent_id]

  belongs_to :card_content, inverse_of: :repetitions
  belongs_to :task, inverse_of: :repetitions

  has_many :answers, inverse_of: :repetition

  validates :card_content, presence: true
  validates :task, presence: true
end
