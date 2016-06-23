# Provides a permanent endpoint for links that must have expiration on AWS
# Converts that url and redirects to a signed AWS link
class ResourceProxyController < ApplicationController
  # no auth

  def url
    if params[:version]
      redirect_to resource.file.url(params[:version])
    else
      redirect_to resource.file.url
    end
  end

  private

  def resource
    ResourceToken.find_by!(token: params[:token]).owner
  end
end
