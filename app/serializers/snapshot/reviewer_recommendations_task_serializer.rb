class Snapshot::ReviewerRecommendationsTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    reviewer_recommendations = model.reviewer_recommendations.order(:id)
    reviewer_recommendations.map do |recommendation|
      Snapshot::ReviewerRecommendationSerializer.new(recommendation).as_json
    end
  end
end
