##
# A related article represents a link to another manuscript, which
# may or may not already be published. Sometimes, two articles should
# be published together, so one needs to be held to wait for the
# other. Other times, they are related, but not simultaneously
# published. Those relationships are one-way.
class RelatedArticle < ActiveRecord::Base
  include ViewableModel
  include CustomCastTypes

  belongs_to :paper

  attribute :linked_title, HtmlString.new
  attribute :additional_info, HtmlString.new
  # Columns available:
  #
  # linked_doi: the DOI of the related article
  #
  # linked_title: the title of the related article
  #
  # additional_info: a free text field
  #
  # send_manuscripts_together: bool, true if this manuscript should be
  # published at the same time as the related article
  #
  # send_link_to_apex: bool, true if the relationship should be sent
  # to Apex for publication
  #

  def user_can_view?(user)
    user.can? :edit_related_articles, paper
  end
end
