class PaperConversionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: :status

  def export
    @export_format = params[:format]
    response = PaperConverter.export(paper, @export_format, current_user)
    render json: { id: response.job_id }, status: :accepted # 201
  end

  def status
    job = PaperConverter.check_status(params[:id])
    render json: JSON.parse(job)
  end

  private

  def enforce_policy
    authorize_action!(resource: paper)
  end

  def paper
    @paper ||= Paper.find(params[:id])
  end
end
