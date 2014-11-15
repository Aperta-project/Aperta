class UserFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :flows

  validates :title, inclusion: { in: FlowTemplate.valid_titles }

  def active_model_serializer
    FlowSerializer
  end
end
