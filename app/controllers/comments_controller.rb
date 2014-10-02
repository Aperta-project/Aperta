class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    task = Task.find(params[:comment][:task_id])
    comment = task.comments.create(comment_params)
    mail_mentioned(comment)

    respond_with comment
  end

  def show
    respond_with Comment.find(params[:id])
  end


  private

  def mail_mentioned(comment)
    # TODO
    # read comment body and parse out names
    # handle duplicate names
    # send email to each user
    people_mentioned = [User.first] # Change me

    people_mentioned.each do |mentionee|
      UserMailer.delay.mention_collaborator(comment.task.assignee.id, mentionee.id, comment.id)
    end
  end

  def comment_params
    params.require(:comment).permit(:commenter_id, :body)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: Task.find(params[:comment][:task_id]))
  end
end
