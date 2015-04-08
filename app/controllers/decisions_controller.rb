class DecisionsController < ApplicationController

  def create
    @paper = Paper.find(params[:decision][:paper_id])
    @decision = @paper.decisions.create!(decision_params)
    render json: @decision, serializer: DecisionSerializer, root: 'decision'
  end

  def update
    @decision = Decision.find(params[:id])
    @decision.update! decision_params
    render json: @decision, serializer: DecisionSerializer, root: 'decision'
  end

  def decision_params
    params.require(:decision).permit(:verdict, :letter)
  end
end
