module TahiStandardTasks
  class Funder < ActiveRecord::Base
    include NestedQuestionable

    belongs_to :task, foreign_key: :task_id
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors

    # useful for nested_questions to always have path to owner
    def paper
      task.paper
    end

    def funding_statement
      return "#{additional_comments}." if only_has_additional_comments?
      s = "This work was supported by #{name} (grant number #{grant_number})."
      s << " #{additional_comments}." if additional_comments.present?
      s
    end

    private

    def only_has_additional_comments?
      additional_comments.present? &&
        !name.present? && !grant_number.present? && !website.present?
    end
  end
end
