class DecisionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    decisions = Decision.where(paper_id: params[:paper_id])

    render json: decisions, each_serializer: DecisionSerializer, root: 'decisions'
  end

  def show
    render json: Decision.find(params[:id]),
           serializer: DecisionSerializer, root: 'decision'
  end

  def create
    paper = Paper.find(params[:decision][:paper_id])

    requires_user_can(:register_decision, paper)

    decision = paper.decisions.create!(decision_params)
    render json: decision, serializer: DecisionSerializer, root: 'decision'
  end

  def update
    requires_user_can(:register_decision, decision.paper)

    decision.update! decision_params
    render json: decision, serializer: DecisionSerializer, root: 'decision'
  end

  def register # I expect a task_id param, too!
    requires_user_can(:register_decision, decision.paper)

    task = Task.find(params[:task_id])
    # These lines let us update the task/paper in the requester's browser
    # without having to serialize the task along with the decision
    task.notify_requester = true
    task.paper.notify_requester = true
    task.register(decision)

    Activity.decision_made! decision, user: current_user

    render json: decision.paper.decisions,
           each_serializer: DecisionSerializer,
           root: 'decisions'
  end

  private

  def decision
    @decision ||= Decision.includes(:paper).find(params[:id])
  end

  def decision_params
    params.require(:decision).permit(:verdict, :letter, :author_response)
  end
end
