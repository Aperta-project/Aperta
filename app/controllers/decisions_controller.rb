class DecisionsController < ApplicationController
  def index
    decisions = Decision.includes(questions: [:question_attachment, :task]).
      where(paper_id: params[:paper_id])

    render json: decisions, each_serializer: DecisionSerializer, root: 'decisions'
  end

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
    params.require(:decision).permit(:verdict, :letter, :author_response)
  end
end
