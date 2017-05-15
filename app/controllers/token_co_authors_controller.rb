# Serves as the method for non-users to conform
# co-authorship without signing in.
class TokenCoAuthorsController < ApplicationController
  before_action :assign_template_vars

  def show
    if @author.co_author_confirmed?
      redirect_to thank_you_token_co_author_path(token)
    end

    # a more elegant handling of this edge case
    #   is handled in a later story
    if @author.co_author_refuted?
      render nothing: true, status: 200, content_type: 'text/html'
    end

    assign_template_vars
  end

  def confirm
    if @author.co_author_confirmed?
      return redirect_to thank_you_token_co_author_path(token)
    end

    @author.co_author_confirmed!
    Activity.co_author_confirmed!(@author, user: current_user)
    redirect_to thank_you_token_co_author_path(token)
  end

  def thank_you
    unless @author.co_author_confirmed?
      redirect_to show_token_co_author_path(token)
    end
  end

  def refuted
    unless author.co_author_refuted?
      redirect_to show_token_co_author_path(token)
    end
    assign_template_vars
  end

  private

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
    GroupAuthor.find_by_token(token) || Author.find_by_token(token)
  end
end
