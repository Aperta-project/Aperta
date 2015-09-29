module Snapshot
  class ReviewerRecommendationsTaskSerializer < BaseSerializer

    def initialize(task)
      @task = task
    end

    def snapshot
      {
        recommendations: snapshot_recommendations
      }
    end

    def snapshot_recommendations
      recommendations = []
      @task.reviewer_recommendations.each do |recommendation|
        serializer = Snapshot::ReviewerRecommendationSerializer.new recommendation
        recommendations << { recommendation: serializer.snapshot }
      end
      recommendations
    end
  end
end
