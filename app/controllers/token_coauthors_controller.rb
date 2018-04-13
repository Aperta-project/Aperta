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

# Allows non-users to confirm co-authorship without signing in.
class TokenCoauthorsController < ApplicationController
  before_action :find_author_by_token
  before_action :verify_coauthor_enabled
  respond_to :json

  def show
    render json: @token_coauthor, serializer: TokenCoauthorSerializer
  end

  def update
    unless @token_coauthor.co_author_confirmed?
      Activity.transaction do
        @token_coauthor.co_author_confirmed!
        Activity.co_author_confirmed!(@token_coauthor, user: current_user)
      end
    end

    render json: @token_coauthor, serializer: TokenCoauthorSerializer
  end

  private

  def verify_coauthor_enabled
    return if @token_coauthor.paper.journal.setting("coauthor_confirmation_enabled").value

    Rails.logger.warn("User attempted to access disabled coauthor functionality")
    render json: {}, status: 404
  end

  def find_author_by_token
    token = params[:token]
    @token_coauthor = GroupAuthor.find_by(token: token) || Author.find_by(token: token)
    return if @token_coauthor

    render json: {}, status: 404
  end
end
