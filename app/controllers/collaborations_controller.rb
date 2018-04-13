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

# End-point for adding and removing collaborators on a paper
class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action do
    raise AuthorizationError unless
      current_user.can?(:manage_collaborators, paper)
  end
  respond_to :json

  def create
    collaboration = paper.add_collaboration(collaborator)
    Activity.collaborator_added!(collaboration, user: current_user)
    UserMailer.delay.add_collaborator(
      current_user.id,
      collaboration.user_id,
      paper.id
    )

    respond_with(
      collaboration,
      serializer: CollaborationSerializer,
      location: nil
    )
  end

  def destroy
    collaboration = paper.remove_collaboration(params[:id])
    Activity.collaborator_removed!(collaboration, user: current_user)

    respond_with collaboration, serializer: CollaborationSerializer
  end

  private

  def collaborator
    @collaborator ||= User.find(collaborator_params[:user_id])
  end

  def collaborator_params
    params.require(:collaboration).permit(:paper_id, :user_id)
  end

  def paper
    @paper ||= begin
      # only the collaboration's id is posted to destroy
      if params[:id]
        Assignment.find(params[:id]).assigned_to
      elsif params[:collaboration]
        # during create all the params are present
        Paper.find_by_id_or_short_doi(collaborator_params[:paper_id])
      end
    end
  end
end
