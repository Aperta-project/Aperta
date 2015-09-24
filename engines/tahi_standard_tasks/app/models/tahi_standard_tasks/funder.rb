module TahiStandardTasks
  class Funder < ActiveRecord::Base
    belongs_to :task, foreign_key: :task_id
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors
    has_many :nested_question_answers, as: :owner, dependent: :destroy

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "funder_had_influence",
        value_type: "boolean",
        text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
        children: [
          NestedQuestion.new(
            owner_id:nil,
            owner_type: name,
            ident: "funder_role_description",
            value_type: "text",
            text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript."
          )
        ]
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def nested_questions
      self.class.nested_questions
    end

  end
end
