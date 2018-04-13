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

class TaskTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_user, except: :create

  respond_to :json

  def show
    respond_with task_template
  end

  def create
    phase = PhaseTemplate.find(task_template_params[:phase_template_id])
    requires_user_can(:administer, phase.journal)
    task_template.save
    respond_with task_template
  end

  def update
    task_template.update_attributes(task_template_params)
    respond_with task_template
  end

  def destroy
    task_template.destroy
    respond_with task_template
  end

  def update_setting
    task_template.setting(params[:name]).update!(value: params[:value])
    respond_with task_template
  end

  private

  def task_template_params
    params.require(:task_template).permit(:title, :phase_template_id, :journal_task_type_id).tap do |whitelisted|
      whitelisted[:template] = params[:task_template][:template] || []
    end
  end

  def journal
    @journal ||= task_template.journal
  end

  def task_template
    @task_template ||= if params[:id]
                         TaskTemplate.find(params[:id])
                       else
                         TaskTemplate.new(task_template_params)
                       end
  end

  def verify_user
    requires_user_can(:administer, journal)
  end
end
