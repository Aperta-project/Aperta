module Snapshot
  class ReviewerRecommendationsTaskSerializer < BaseSerializer

    def initialize(task)
      @task = task
    end

    def snapshot
      recommendations = []

      @task.reviewer_recommendations.each do |recommendation|
        puts recommendation
        serializer = Snapshot::ReviewerRecommendationSerializer.new recommendation
        recommendations << ["recommendation", serializer.snapshot]
      end
      recommendations
    end
  end
end
