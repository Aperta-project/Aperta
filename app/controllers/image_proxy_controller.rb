class ImageProxyController < ActionController::Base
  before_action :authenticate_user!

  def show
    attachment = Figure.find(params[:figure_id]).attachment

    s3_url = if params[:version].present?
              attachment.url(params[:version])
            else
              attachment.url
            end

    redirect_to s3_url
  end
end
