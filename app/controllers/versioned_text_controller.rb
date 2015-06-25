class VersionedTaskController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def show
    respond_with(versioned_text, location: versioned_text_url(versioned_text))
  end

  def enforce_policy
    authorize_action!(paper: versioned_text.paper)
  end
end
