class PaperVersionsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def show
    requires_user_can(:view, paper_version.paper)
    respond_with(paper_version, location: paper_version_url(paper_version))
  end

  private

  def paper_version
    @paper_version ||= PaperVersion.find(params[:id])
  end
end
