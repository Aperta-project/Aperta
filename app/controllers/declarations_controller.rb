class DeclarationsController < ApplicationController

  def update
    @declaration = Declaration.find(params[:id])
    @declaration.update_attributes(declaration_params)
    head :update
  end

  private

  def declaration_params
    params.require(:declaration).permit(:answer)
  end
end
