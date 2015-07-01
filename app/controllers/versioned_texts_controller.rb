class VersionedTextsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def show
    respond_with(versioned_text, location: versioned_text_url(versioned_text))
  end

  def enforce_policy
    authorize_action!(versioned_text: versioned_text)
  end

  private

  def versioned_text
    @versioned_text ||= begin
      if params[:id].present?
        VersionedText.find(params[:id])
      end
    end
  end
end
