class UserInfoController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def dashboard
    assigned_tasks = current_user.tasks.includes({paper: :message_tasks}, :assignee)
    @tasks = assigned_tasks.group_by { |t| t.paper }.map do |paper, tasks|
      {id: paper.id, _tasks: serialize_tasks(paper.message_tasks + tasks)}
    end
    @task_papers = assigned_tasks.map(&:paper).uniq
    @user_papers = current_user.papers.includes(task_manager: :phases)
    @all_submitted_papers = Paper.submitted.includes(task_manager: :phases) if current_user.admin?

    render json: {}, serializer: DashboardSerializer
  end

  private
  def serialize_tasks(tasks)
    ActiveModel::ArraySerializer.new(tasks, each_serializer: DashboardTaskSerializer)
  end
end

