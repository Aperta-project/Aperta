class SurveysController < ApplicationController
  before_action :authenticate_user!
  respond_to :json
  def update
    survey = Survey.find(params[:id])
    survey.update_attributes(survey_params)
    respond_with survey
  end

  private

  def survey_params
    params.require(:survey).permit(:answer)
  end
end
