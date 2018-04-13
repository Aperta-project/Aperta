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

# Handle Correspondence: both internal and external
class CorrespondenceController < ApplicationController
  before_action :authenticate_user!, :ensure_paper

  respond_to :json

  def index
    render json: @paper.correspondence
  end

  def create
    correspondence = @paper.correspondence.build correspondence_params
    correspondence.sent_at = params.dig(:correspondence, :date)
    if correspondence.save
      Activity.correspondence_created! correspondence, user: current_user
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  def show
    render json: correspondence, status: :ok
  end

  def update
    if correspondence && correspondence.external?
      Correspondence.transaction do
        correspondence.sent_at = params.dig(:correspondence, :date)
        correspondence.update!(correspondence_params)
        if correspondence_params[:status] == 'deleted'
          Activity.correspondence_deleted! correspondence, user: current_user
        else
          Activity.correspondence_edited! correspondence, user: current_user
        end
      end
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  private

  def correspondence_params
    params.require(:correspondence).permit(
      :cc,
      :bcc,
      :sender,
      :recipients,
      :description,
      :subject,
      :body,
      :external,
      :status,
      additional_context: [:delete_reason]
    )
  end

  def correspondence
    @correspondence ||= Correspondence.find(params[:id])
  end

  def ensure_paper
    paper_id = params.dig(:correspondence, :paper_id) || params[:paper_id]
    if paper_id
      @paper = Paper.find paper_id
    else
      @paper = correspondence.paper
    end

    if @paper
      requires_user_can :manage_workflow, @paper
    else
      render :not_found
    end
  end
end
