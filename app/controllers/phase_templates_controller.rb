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

class PhaseTemplatesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:administer, journal)
    phase_template.save
    respond_with phase_template
  end

  def update
    requires_user_can(:administer, journal)
    phase_template.update_attributes(phase_template_params)
    respond_with phase_template
  end

  def destroy
    requires_user_can(:administer, journal)
    phase_template.destroy
    respond_with phase_template
  end

  private

  def journal
    phase_template.journal
  end

  def phase_template_params
    params.require(:phase_template).permit(:name, :manuscript_manager_template_id, :position)
  end

  def phase_template
    @phase_template ||= if params[:id]
      PhaseTemplate.find(params[:id])
    else
      PhaseTemplate.new(phase_template_params)
    end
  end
end
