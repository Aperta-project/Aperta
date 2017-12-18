# Serves as the method for non-users to conform
# co-authorship without signing in.
class TokenCoAuthorsController < ApplicationController
  before_action :assign_template_vars
  before_action :verify_coauthor_enabled

  def show
    render(:thank_you) && return if @author.co_author_confirmed?

    # a more elegant handling of this edge case may be handled in a later story
    if @author.co_author_refuted?
      render(nothing: true, status: 200, content_type: 'text/html') && return
    end
  end

  def confirm
    unless @author.co_author_confirmed?
      @author.co_author_confirmed!
      Activity.co_author_confirmed!(@author, user: current_user)
    end

    render(:thank_you) && return
  end

  private

  def verify_coauthor_enabled
    unless @paper.journal.setting("coauthor_confirmation_enabled").value
      Rails.logger.warn("User attempted to access disabled coauthor functionality")
      render status: 404
    end
  end

  def assign_template_vars
    @author ||= find_author_by_token
    @paper ||= @author.paper
    @authors ||= @paper.all_authors
    @journal_logo_url ||= @paper.journal.logo_url
  end

  def token
    params[:token] || params[:invitation][:token]
  end

  # We have to check both since coauthorship is across models
  def find_author_by_token
    GroupAuthor.find_by(token: token) || Author.find_by(token: token)
  end
end
