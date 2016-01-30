class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  before_action :enforce_index_policy, only: [:index]

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    respond_with task.comments, root: :comments
  end

  def create
    if !current_user.journal_admin? task.paper.journal
      ParticipationFactory.create(task: comment.task, assignee: current_user, assigner: current_user)
    end
    Activity.comment_created! comment, user: current_user
    respond_with comment if CommentLookManager.sync_comment(comment)
  end

  def show
    respond_with comment
  end

  private

  def task
    @task ||= begin
      if params[:id].present?
        comment.task
      else
        Task.find(comment_params[:task_id])
      end
    end
  end

  def comment
    @comment ||= begin
      if params[:id].present?
        Comment.find(params[:id])
      else
        task.comments.build(comment_params)
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:commenter_id, :body, :task_id)
  end

  def render_404
    head 404
  end

  def enforce_index_policy
    @task = Task.find(params[:task_id])
    if !current_user.can?(:view, @task)
      fail AuthorizationError
    end
  end

  def enforce_policy
    if !current_user.can?(:view, task)
      fail AuthorizationError
    end
  end
end
