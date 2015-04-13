class PaperConversionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: :status

  def export
    @export_format = params[:format]
    response = PaperConverter.export(paper, @export_format, current_user)
    render json: JSON.parse(response), status: :non_authoritative_information # 203
  end

  def status
    job = PaperConverter.check_status(params[:id])
    render json: JSON.parse(job)
  end

  def fake_render_latex
    puts params
    render json: { latex_image_url: "http://placekitten.com/g/200/#{300 + rand(50)}" }
  end

  private

  def enforce_policy
    authorize_action!(resource: paper)
  end

  def paper
    @paper ||= Paper.find(params[:id])
  end
end
