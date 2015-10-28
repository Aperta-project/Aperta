class Snapshot::ReviewerRecommendationsTaskSerializer < Snapshot::BaseSerializer
  def initialize(task)
    @task = task
  end

  def as_json
    { name: "recommendations", type: "properties", children: snapshot_recommendations }
  end

  def snapshot_recommendations
    reviewer_recommendations = @task.reviewer_recommendations.order(:id)
    reviewer_recommendations.map do |recommendation|
      Snapshot::ReviewerRecommendationSerializer.new(recommendation).as_json
    end
  end
end
