module Snapshot
  class ReviewerRecommendationSerializer < BaseSerializer

    def initialize(reviewer_recommendation)
      @reviewer_recommendation = reviewer_recommendation
    end

    def snapshot
      recommendation_snapshot = []
      nested_questions = TahiStandardTasks::ReviewerRecommendation.nested_questions.where(parent_id: nil).order('id')

      nested_questions.each do |question|
        question_serializer = Snapshot::NestedQuestionSerializer.new question, @reviewer_recommendation
        recommendation_snapshot << question_serializer.snapshot
      end

      recommendation_snapshot
    end

  end
end
