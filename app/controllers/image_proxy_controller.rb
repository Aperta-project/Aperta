class ImageProxyController < ActionController::Base
  before_action :authenticate_user!

  def show
    attachment = Figure.find(params[:figure_id]).attachment

    if params[:version].present?
      s3_url = attachment.url(params[:version])
    else
      s3_url = attachment.url
    end

    redirect_to s3_url
  end
end
