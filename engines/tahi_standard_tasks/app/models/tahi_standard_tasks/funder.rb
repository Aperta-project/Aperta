module TahiStandardTasks
  class Funder < ActiveRecord::Base
    include NestedQuestionable

    belongs_to :task, foreign_key: :task_id
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

  end
end
