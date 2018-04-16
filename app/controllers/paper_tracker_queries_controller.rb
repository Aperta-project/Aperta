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

# Saves searches that editors use on a regular basis
class PaperTrackerQueriesController < ApplicationController
  before_action :authenticate_user!, :authorize

  respond_to :json

  def index
    queries = PaperTrackerQuery.all
    render(
      json: queries,
      each_serializer: PaperTrackerQuerySerializer,
      root: 'paper_tracker_queries'
    )
  end

  def create
    respond_with PaperTrackerQuery.create(query_params)
  end

  def update
    respond_with query.update(query_params)
  end

  def destroy
    title = query.title
    query.update(deleted: true)
    Rails.logger.info("#{current_user.email} deleted query #{title}")
    head :no_content
  end

  private

  def query
    PaperTrackerQuery.find(params[:id])
  end

  def query_params
    params.require(:paper_tracker_query).permit(:title, :query, :order_by, :order_dir)
  end

  def journals
    current_user.filter_authorized(
      :view_paper_tracker,
      Journal,
      participations_only: false
    ).objects
  end

  def authorize
    raise AuthorizationError if journals.empty?
  end
end
