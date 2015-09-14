class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
  has_many :nested_question_answers

  validates :ident, presence: true
  validates :owner_type, presence: true
  validates :value_type, presence: true

  # A question itself doesn't have a single answer so we don't save answers
  # here. However, it sure is nice when working with questions in a particular
  # context to be able to easily access its answer.
  #
  # By providing a virtual accessor here we allow an object to set the value
  # so it can pass the question around in a given context... and make life easier
  # for anyone interested in the answer.
  attr_accessor :value
end
