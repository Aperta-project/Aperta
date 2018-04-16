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

# +PaperRoleUsersController+ is responsible for communicating eligible users for
# a given paper and role.
class PaperRoleEligibleUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:view_user_role_eligibility_on_paper, paper)
    role = Role.find_by!(id: params[:role_id], journal_id: paper.journal_id)
    eligible_users = EligibleUserService.eligible_users_for(
      paper: paper,
      role: role,
      matching: params[:query]
    )
    render json: eligible_users, each_serializer: SensitiveInformationUserSerializer, root: 'users'
  end

  private

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id])
  end
end
