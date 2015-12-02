# Provides a permanent endpoint for links that must have expiration on AWS
# Converts that url and redirects to a signed AWS link
class ResourceProxyController < ApplicationController
  # no auth

  before_action :enforce_whitelist
  before_action :find_resource

  def url
    if params[:version]
      redirect_to @resource.attachment.url(params[:version])
    else
      redirect_to @resource.attachment.url
    end
  end

  private

  def resource_whitelist
    ['supporting_information_files']
  end

  def enforce_whitelist
    unless resource_whitelist.include? params[:resource]
      fail ActionController::RoutingError
        .new('proxy url not available for this resource')
    end
  end

  def find_resource
    @resource ||=
      params[:resource].classify.constantize.find_by_token! params[:token]
  end
end
