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
    requires_user_can_view related_article
    render json: related_article
  end

  def create
    paper = Paper.find_by_id_or_short_doi(related_article_params[:paper_id])
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
