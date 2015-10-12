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

  def attachment?
    value_type == "attachment"
  end
end
