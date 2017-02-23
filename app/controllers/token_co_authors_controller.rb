# Serves as the method for non-users to conform co-authorship without signing in.
class TokenCoAuthorsController < ApplicationController
  before_action :assign_template_vars

  def show
    if @author.co_author_confirmed?
      redirect_to thank_you_token_co_author_path(token)
    end
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
    redirect_to show_token_co_author_path(token) unless @author.co_author_confirmed?
  end

  private

  def assign_template_vars
    @author ||= Author.find_by_token!(token)
    @paper ||= @author.paper
    @authors ||= @paper.all_authors
    @journal_logo_url ||= @paper.journal.logo_url
  end

  def token
    params[:token] || params[:invitation][:token]
  end
end
