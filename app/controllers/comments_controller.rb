# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class CommentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    requires_user_can :view_discussion_footer, task
    respond_with task.comments, root: :comments
  end

  def create
    requires_user_can :edit_discussion_footer, task
    Activity.comment_created! comment, user: current_user
    respond_with comment if CommentLookManager.sync_comment(comment)
  end

  def show
    requires_user_can :view_discussion_footer, task
    respond_with comment
  end

  private

  def task
    @task ||= begin
      if params[:id].present?
        comment.task
      elsif params[:task_id]
        Task.find(params[:task_id])
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
end
