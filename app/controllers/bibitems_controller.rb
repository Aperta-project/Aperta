class BibitemsController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    bibitem.update_attributes(bibitem_params)
    respond_with bibitem
  end

  def update
    bibitem.update_attributes(bibitem_params)
    respond_with bibitem
  end

  def destroy
    bibitem.destroy
    head :no_content
  end

  private

  def paper
    @paper ||= Paper.find(params[:bibitem][:paper_id])
  end

  def bibitem
    @bibitem ||= begin
      if params[:id].present?
        Bibitem.find(params[:id])
      else
        paper.bibitems.new
      end
    end
  end

  def enforce_policy
    authorize_action!(resource: bibitem)
  end

  def bibitem_params
    params.require(:bibitem).permit(:format, :content)
  end

  def render_404
    head 404
  end
end
