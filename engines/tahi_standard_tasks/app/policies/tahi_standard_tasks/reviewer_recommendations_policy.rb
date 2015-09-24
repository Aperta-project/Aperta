module TahiStandardTasks
  class ReviewerRecommendationsPolicy < ApplicationPolicy
    primary_resource :reviewer_recommendation
    include TaskAccessCriteria

    def show?
      authorized_to_modify_task?
    end

    def create?
      authorized_to_modify_task?
    end

    def update?
      authorized_to_modify_task?
    end

    def destroy?
      authorized_to_modify_task?
    end

    private

    def task
      reviewer_recommendation.reviewer_recommendations_task
    end

    def papers_policy
      @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: task.paper)
    end
  end
end
