class PaperConversionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def export
    @paper = Paper.find(params[:id])
    @export_format = params[:format]
    response = PaperConverter.export(@paper, @export_format, current_user)
    render json: JSON.parse(response), status: :non_authoritative_information # 203
  end

  def status
    job = PaperConverter.check_status(params[:id])
    render json: JSON.parse(job)
  end

  private

  def enforce_policy
    authorize_action!(resource: @paper)
  end
end
