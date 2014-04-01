class UserInfoController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def thumbnails
    @users = User.all
    render "user_info/thumbnails.json.jbuilder"
  end

  def dashboard
    assigned_tasks = current_user.tasks.includes(:paper)
    @tasks = assigned_tasks.group_by { |t| t.paper.id }.map do |id, tasks|
      {id: id, tasks: tasks}
    end
    @task_papers = assigned_tasks.map(&:paper).uniq
    @user_papers = current_user.papers
    @all_submitted_papers = Paper.submitted if current_user.admin?

    render json: { user: current_user, submissions: @user_papers, task_papers: @task_papers, assigned_tasks: @tasks}
  end
end
