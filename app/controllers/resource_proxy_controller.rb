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
    whitelisted_resource!.classify.constantize.find_by_token! params[:token]
  end

  def whitelisted_resource!
    enforce_whitelist
    params[:resource]
  end

  def resource_whitelist
    [
      :attachments,
      :adhoc_attachments,
      :figures,
      :question_attachments,
      :supporting_information_files
    ]
  end

  def enforce_whitelist
    unless resource_whitelist.include? params[:resource].to_sym
      fail ActionController::RoutingError
        .new('proxy url not available for this resource')
    end
  end
end
