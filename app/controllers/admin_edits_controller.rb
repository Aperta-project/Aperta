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

##
# Controller for routes handling admin edits
#
# An admin edit record contains notes pertaining to why a reviewer report was
# edited by an admin. Reports may have multiple admin edit records, but only
# one of them can be active at a time, indicating the report is currently
# being edited. While editing is going on, updates to the report's answers
# will by saved to a field in the answer's additional_info hash rather than the
# main answer value.
#
# When an admin updated to change the status to completed, the additional_info
# field gets copied to the answer value, then purged. If an admin edit record
# is deleted, the additional_info field is also purged, but no answer value
# update takes place
#
class AdminEditsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :edit_answers, paper
    render json: admin_edit
  end

  def create
    requires_user_can :edit_answers, paper
    render json: AdminEdit.edit_for(reviewer_report)
  end

  def update
    requires_user_can :edit_answers, paper
    unless admin_edit_params["active"]
      reviewer_report.answers.each do |answer|
        additional = answer.additional_data || {}
        value = additional["pending_edit"]
        additional["pending_edit"] = nil
        answer.update(additional_data: additional, value: value)
      end
      admin_edit.user = current_user
    end

    admin_edit.update!(admin_edit_params)
    render json: admin_edit
  end

  def destroy
    reviewer_report = admin_edit.reviewer_report
    requires_user_can :edit_answers, reviewer_report.paper

    reviewer_report.answers.each do |answer|
      additional = answer.additional_data || {}
      additional["pending_edit"] = nil
      answer.update(additional_data: additional)
    end

    admin_edit.destroy!
    head :no_content
  end

  private

  def admin_edit
    @admin_edit ||= AdminEdit.find(params[:id])
  end

  def reviewer_report
    @reviewer_report ||= ReviewerReport.find(admin_edit_params[:reviewer_report_id])
  end

  def paper
    @paper ||= reviewer_report.paper
  end

  def admin_edit_params
    params.require(:admin_edit).permit(
      :reviewer_report_id,
      :active,
      :notes
    )
  end
end
