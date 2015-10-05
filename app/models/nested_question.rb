class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true
  has_many :nested_question_answers, dependent: :destroy

  validates :ident, presence: true
  validates :owner_type, presence: true
  validates :value_type, presence: true

  def self.lookup_owner_type(owner_type)
    case owner_type
    when /Task$/
      "Task"
    when "Author"
      Author.name
    when "Funder"
      TahiStandardTasks::Funder.name
    when "ReviewerRecommendation"
      TahiStandardTasks::ReviewerRecommendation.name
    else
      raise "Don't know how to assign to #{owner_type}"
    end
  end

  # A question itself doesn't have a single answer so we don't save answers
  # here. However, it sure is nice when working with questions in a particular
  # context to be able to easily access its answer.
  #
  # By providing a virtual accessor here we allow an object to set the value
  # so it can pass the question around in a given context... and make life easier
  # for anyone interested in the answer.
  attr_accessor :value

  def attachment?
    value_type == "attachment"
  end
end
