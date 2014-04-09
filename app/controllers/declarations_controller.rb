class DeclarationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json
  def update
    declaration = Declaration.find(params[:id])
    declaration.update_attributes(declaration_params)
    respond_with declaration
  end

  private

  def declaration_params
    params.require(:declaration).permit(:answer)
  end
end
