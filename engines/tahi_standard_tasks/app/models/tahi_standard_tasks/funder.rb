module TahiStandardTasks
  class Funder < ActiveRecord::Base
    include Answerable

    belongs_to :task, foreign_key: :task_id
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors

    # NestedQuestionAnswersController will save the paper_id to newly created
    # answers if an answer's owner responds to :paper. This method is needed by
    # the NestedQuestionAnswersController#fetch_answer method, among others
    def paper
      task.paper
    end

    def funding_statement
      return additional_comments.to_s if only_has_additional_comments?
      s = "#{name} #{website} (grant number #{grant_number})."
      s << " #{additional_comments}." if additional_comments.present?
      s << if influence
             " #{influence_description}."
           else
             " The funder had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript."
           end
      s
    end

    def influence
      answer_for('funder--had_influence').try(:value)
    end

    def influence_description
      answer_for('funder--had_influence--role_description').try(:value)
    end

    private

    def only_has_additional_comments?
      additional_comments.present? &&
        !name.present? && !grant_number.present? && !website.present?
    end
  end
end
