class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  respond_to :json

  def update
    @journal = Journal.find(params[:id])

    if @journal.update(journal_params)
      render json: @journal
    else
      respond_with @journal
    end
  end

  private
  def journal_params
    params.require(:journal).permit(:epub_cover)
  end
end
