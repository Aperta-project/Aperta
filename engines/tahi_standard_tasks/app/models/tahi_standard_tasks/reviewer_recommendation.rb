module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    belongs_to :reviewer_recommendations_task
    has_many :nested_question_answers, as: :owner, dependent: :destroy

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id: nil,
        owner_type: name,
        ident: "recommend_or_oppose",
        value_type: "text",
        text: "Are you recommending or opposing this reviewer? (required)"
      )
      questions << NestedQuestion.new(
        owner_id: nil,
        owner_type: name,
        ident: "reason",
        value_type: "text",
        text: "Optional: reason for recommending or opposing this reviewer"
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def nested_questions
      nested_questions = TahiStandardTasks::ReviewerRecommendation.nested_questions
      nested_questions.each do |nested_question|
        nested_question.owner = self
      end
      nested_questions
    end
  end
end
