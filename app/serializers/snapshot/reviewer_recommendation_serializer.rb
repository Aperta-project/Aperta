class Snapshot::ReviewerRecommendationSerializer < Snapshot::BaseSerializer
  def initialize(reviewer_recommendation)
    @reviewer_recommendation = reviewer_recommendation
  end

  def as_json
    { name: "reviewer_recommendation",
      type: "properties",
      children: snapshot_properties + snapshot_nested_questions }
  end

  def snapshot_properties
    [
      snapshot_property("first_name", "text", @reviewer_recommendation.first_name),
      snapshot_property("last_name", "text", @reviewer_recommendation.last_name),
      snapshot_property("middle_initial", "text", @reviewer_recommendation.middle_initial),
      snapshot_property("email", "text", @reviewer_recommendation.email),
      snapshot_property("department", "text", @reviewer_recommendation.department),
      snapshot_property("title", "text", @reviewer_recommendation.title),
      snapshot_property("affiliation", "text", @reviewer_recommendation.affiliation),
      snapshot_property("ringgold_id", "text", @reviewer_recommendation.ringgold_id)
    ]
  end

  def snapshot_nested_questions
    nested_questions = TahiStandardTasks::ReviewerRecommendation.nested_questions.where(parent_id: nil).order('position')

    nested_questions.map do |question|
      Snapshot::NestedQuestionSerializer.new(question, @reviewer_recommendation).as_json
    end
  end
end
