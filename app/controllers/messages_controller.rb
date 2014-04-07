class MessageTasksController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def update_participants
    task = Task.find(params[:id])
    p = PaperPolicy.new task.paper, current_user
    if p.paper
      task.update_attributes! update_participants_params
      @users = task.participants
      respond_to do |f|
        f.json { render "user_info/thumbnails" }
      end
    else
      head 404
    end
  end

 private

  def update_participants_params
    params.require(:task).permit({participant_ids: []})
  end

  def render_404
    head 404
  end

end
