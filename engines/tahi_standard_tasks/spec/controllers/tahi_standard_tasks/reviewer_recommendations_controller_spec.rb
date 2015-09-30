require 'rails_helper'

module TahiStandardTasks
  describe ReviewerRecommendationsController do
    routes { TahiStandardTasks::Engine.routes }

    let(:user) { paper.creator }
    let(:paper) { FactoryGirl.create(:paper_with_phases) }
    let(:task) { FactoryGirl.create(:reviewer_recommendations_task, phase: paper.phases.last) }

    before do
      sign_in user
    end

    describe "POST #create" do
      def do_request
        post :create, format: :json, reviewer_recommendation: {
          first_name: "enrico",
          last_name: "fermi",
          reviewer_recommendations_task_id: task.id,
          position: 1
        }
      end

      it "creates a new reviewer_recommendation" do
        expect { do_request }.to change { ReviewerRecommendation.count }.by 1
      end
    end
  end
end
