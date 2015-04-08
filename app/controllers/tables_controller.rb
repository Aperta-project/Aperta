class TablesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy

  def create
    table.update_attributes(table_params)
    respond_with table
  end

  def update
    table.update_attributes(table_params)
    respond_with table
  end

  def destroy
    table.destroy
    head :no_content
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def table
    @table ||= begin
      if params[:id].present?
        Table.find(params[:id])
      else
        paper.tables.new
      end
    end
  end

  def enforce_policy
    authorize_action!(resource: table)
  end

  def table_params
    params.require(:table).permit(:title, :caption, :body)
  end

  def render_404
    head 404
  end
end
