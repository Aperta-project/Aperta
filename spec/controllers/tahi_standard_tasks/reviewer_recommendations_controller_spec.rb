# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

module TahiStandardTasks
  describe ReviewerRecommendationsController do
    before do
      CardLoader.load("TahiStandardTasks::Funder")
      CardLoader.load("TahiStandardTasks::ReviewerRecommendation")
    end

    let(:user) { FactoryGirl.create :user }
    let(:journal) do
      FactoryGirl.create(
        :journal,
        :with_creator_role
      )
    end

    let(:paper) do
      FactoryGirl.create(
        :paper_with_phases,
        creator: user,
        journal: journal
      )
    end

    let(:task) do
      FactoryGirl.create(
        :reviewer_recommendations_task,
        :with_loaded_card,
        paper: paper,
        phase: paper.phases.last
      )
    end

    describe "POST #create" do
      subject(:do_request) do
        post :create, format: :json, reviewer_recommendation: {
          first_name: "enrico",
          last_name: "fermi",
          email: "enrico@example.com",
          recommend_or_oppose: "Recommend",
          reviewer_recommendations_task_id: task.id,
          position: 1
        }
      end

      context "the user is authenticated" do
        before do
          stub_sign_in user
        end

        context "when the user has access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return true
          end

          it "returns 201" do
            do_request
            expect(response.status).to eq(201)
          end

          it "creates a new reviewer_recommendation" do
            expect { do_request }
              .to change { ReviewerRecommendation.count }.by 1
          end
        end

        context "when the user does not have access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return false
          end

          it "returns 403" do
            do_request
            expect(response.status).to eq(403)
          end
        end
      end
    end

    describe "POST #update" do
      let(:recommendation) do
        FactoryGirl.create(:reviewer_recommendation, first_name: "Not Steve")
      end

      let(:task) { recommendation.task }

      subject(:do_request) do
        post :update,
          format: :json,
          id: recommendation.id,
          reviewer_recommendation: {
            first_name: "Steve"
          }
      end

      context "the user is authenticated" do
        before do
          stub_sign_in user
        end

        context "when the user has access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return true

            do_request
          end

          it "returns 200" do
            expect(response.status).to eq(200)
          end

          it "updates the recommendation" do
            expect(recommendation.reload.first_name).to eq("Steve")
          end
        end

        context "when the user does not have access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return false
          end

          it "returns 403" do
            do_request
            expect(response.status).to eq(403)
          end
        end
      end
    end

    describe "#destroy" do
      let(:recommendation) do
        FactoryGirl.create(:reviewer_recommendation, first_name: "Not Steve")
      end

      let(:task) { recommendation.task }

      subject(:do_request) do
        delete :destroy,
          format: :json,
          id: recommendation.id
      end

      context "the user is authenticated" do
        before do
          stub_sign_in user
        end

        context "when the user has access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return true

          end

          it "returns 204" do
            do_request
            expect(response.status).to eq(204)
          end

          it "destroys the recommendation" do
            expect { do_request }
              .to change { ReviewerRecommendation.count }.by -1
          end
        end

        context "when the user does not have access" do
          before do
            allow(user).to receive(:can?)
              .with(:edit, task)
              .and_return false
          end

          it "returns 403" do
            do_request
            expect(response.status).to eq(403)
          end
        end
      end
    end
  end
end
