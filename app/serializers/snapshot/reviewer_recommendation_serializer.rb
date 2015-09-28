module Snapshot
  class ReviewerRecommendationSerializer < BaseSerializer

    def initialize(reviewer_recommendation)
      @reviewer_recommendation = reviewer_recommendation
    end

    def snapshot
      recommendation = []
      recommendation << ["properties", snapshot_properties]
      recommendation << ["questions", snapshot_nested_questions]
    end

    def snapshot_properties
      properties = []
      properties << snapshot_property("first_name", "text", @reviewer_recommendation.first_name)
      properties << snapshot_property("last_name", "text", @reviewer_recommendation.last_name)
      properties << snapshot_property("middle_initial", "text", @reviewer_recommendation.middle_initial)
      properties << snapshot_property("email", "text", @reviewer_recommendation.email)
      properties << snapshot_property("department", "text", @reviewer_recommendation.department)
      properties << snapshot_property("title", "text", @reviewer_recommendation.title)
      properties << snapshot_property("affiliation", "text", @reviewer_recommendation.affiliation)
      properties << snapshot_property("ringgold_id", "text", @reviewer_recommendation.ringgold_id)
    end

    def snapshot_nested_questions
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
