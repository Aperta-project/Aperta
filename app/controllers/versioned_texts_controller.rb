class VersionedTextsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def show
    requires_user_can(:view, versioned_text.paper)
    respond_with(versioned_text, location: versioned_text_url(versioned_text))
  end

  private

  def versioned_text
    @versioned_text ||= VersionedText.find(params[:id])
  end
end
