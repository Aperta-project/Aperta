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

class PhasesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: [:show, :index]
  respond_to :json

  def index
    requires_user_can(:view, paper)
    respond_with paper.phases
  end

  def create
    respond_with paper.phases.create!(new_phase_params)
  end

  def update
    phase.update_attributes! update_phase_params
    respond_with phase
  end

  def show
    requires_user_can(:view, phase.paper)
    respond_with phase
  end

  def destroy
    if phase.tasks.empty? && phase.destroy
      render json: true
    else
      render :nothing => true, :status => 400
    end
  end

  private

  def new_phase_params
    params.require(:phase).permit(:name, :position)
  end

  def update_phase_params
    params.require(:phase).permit(:name)
  end

  def phase
    @phase ||= Phase.find_by(id: params[:id])
  end

  def paper
    # rubocop:disable Rails/DynamicFindBy
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id] || params.dig(:phase, :paper_id))
    # rubocop:enable Rails/DynamicFindBy
  end

  def authorize_user
    requires_user_can(:manage_workflow, (params[:id] ? phase.paper : paper))
  end
end
