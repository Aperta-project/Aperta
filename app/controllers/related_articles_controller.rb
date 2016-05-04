##
# Controller for routes handling related articles
#
# A related article represents a link to another manuscript, which
# may or may not already be published. Sometimes, two articles should
# be published together, so one needs to be held to wait for the
# other. Other times, they are related, but not simultaneously
# published. Those relationships are one-way.
#
class RelatedArticlesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :edit_related_articles, related_article.paper
    render json: related_article
  end

  def create
    paper = Paper.find(related_article_params[:paper_id])
    requires_user_can :edit_related_articles, paper

    related_article = RelatedArticle.new(related_article_params)
    related_article.save!

    render json: related_article
  end

  def update
    requires_user_can :edit_related_articles, related_article.paper
    related_article.update!(related_article_params)

    render json: related_article
  end

  def destroy
    requires_user_can :edit_related_articles, related_article.paper
    related_article.destroy!

    render json: related_article
  end

  private

  def related_article
    @related_article ||= RelatedArticle.find(params[:id])
  end

  def related_article_params
    params.require(:related_article).permit(
      :paper_id,
      :linked_doi,
      :linked_title,
      :additional_info,
      :send_manuscripts_together,
      :send_link_to_apex
    )
  end
end
