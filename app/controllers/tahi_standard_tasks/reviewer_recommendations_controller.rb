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

module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.save!
      render json: reviewer_recommendation, status: :created
    end

    def update
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.update!(reviewer_recommendation_params)
      render json: reviewer_recommendation
    end

    def destroy
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.destroy!
      head :no_content
    end

    private

    def reviewer_recommendation
      @reviewer_recommendation ||= begin
        if params[:id]
          ReviewerRecommendation.find(params[:id])
        else
          ReviewerRecommendation.new(reviewer_recommendation_params)
        end
      end
    end

    def reviewer_recommendation_params
      params.require(:reviewer_recommendation).permit(
        :reviewer_recommendations_task_id,
        :first_name,
        :middle_initial,
        :last_name,
        :email,
        :title,
        :department,
        :affiliation,
        :ringgold_id
      )
    end
  end
end
