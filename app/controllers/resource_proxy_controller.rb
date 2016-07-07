# Provides a permanent endpoint for links that must have expiration on AWS
# Converts that url and redirects to a signed AWS link
class ResourceProxyController < ApplicationController
  # no auth

  def url
    deproxied_url = resource.url(params[:version])
    unless deproxied_url
      fail(ActiveRecord::RecordNotFound,
           "Couldn't find url for token #{params[:token]} and version" \
           "#{params[:version] || 'default'}")
    end
    redirect_to deproxied_url
  end

  private

  def resource
    ResourceToken.find_by!(token: params[:token])
  end
end
