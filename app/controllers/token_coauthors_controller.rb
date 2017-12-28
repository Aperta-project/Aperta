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
