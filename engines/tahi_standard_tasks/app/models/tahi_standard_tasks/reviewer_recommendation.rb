module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    include NestedQuestionable

    belongs_to :reviewer_recommendations_task

    validates :email, presence: true

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id: nil,
        owner_type: name,
        ident: "recommend_or_oppose",
        value_type: "boolean",
        text: "Are you recommending or opposing this reviewer? (required)",
        position: 1
      )
      questions << NestedQuestion.new(
        owner_id: nil,
        owner_type: name,
        ident: "reason",
        value_type: "text",
        text: "Optional: reason for recommending or opposing this reviewer",
        position: 2
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
