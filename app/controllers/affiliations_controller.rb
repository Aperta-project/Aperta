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

class AffiliationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    query = params.dig(:query)
    if not query
      institutions = []
    else
      institutions = Institutions.instance.matching_institutions(query)
    end
    render json: institutions, root: :institutions
  end

  def for_user
    current_user.id == params[:user_id].to_i ||
      requires_user_can(:manage_users, Journal)

    render json: Affiliation.where(user_id: params[:user_id])
  end

  def show
    current_user == affiliation.user ||
      requires_user_can(:manage_users, Journal)

    render json: affiliation
  end

  def update
    (current_user == affiliation.user &&
     current_user.id == affiliation_params[:user_id].to_i) ||
      requires_user_can(:manage_users, Journal)

    affiliation.update_attributes! affiliation_params
    respond_with affiliation
  end

  def create
    (current_user == user &&
     current_user.id == affiliation_params[:user_id].to_i) ||
      requires_user_can(:manage_users, Journal)

    new_affiliation = user.affiliations.create!(affiliation_params)
    render json: new_affiliation
  end

  def destroy
    current_user == affiliation.user ||
      requires_user_can(:manage_users, Journal)

    if affiliation.try(:destroy)
      render json: true
    else
      render status: 400
    end
  end

  private

  def user
    @user ||= begin
      User.find(params[:user_id] || affiliation_params[:user_id])
    end
  end

  def affiliation
    @affiliation ||= begin
      Affiliation.find(params[:id])
    end
  end

  def affiliation_params
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email, :department, :title, :country, :ringgold_id, :user_id)
  end
end
