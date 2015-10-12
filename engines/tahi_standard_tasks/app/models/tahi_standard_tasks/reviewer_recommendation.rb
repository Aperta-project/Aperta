module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    belongs_to :reviewer_recommendations_task
    has_many :nested_question_answers, as: :owner, dependent: :destroy

    validates :email, presence: true
    validates :recommend_or_oppose, presence: true

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
      self.class.nested_questions
    end
  end
end
