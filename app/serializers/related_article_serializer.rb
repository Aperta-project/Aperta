# Serializes related articles, which represent links between
# this manuscript and others, published or not.
class RelatedArticleSerializer < AuthzSerializer
  attributes :id,
             :paper_id,
             :linked_doi,
             :linked_title,
             :additional_info,
             :send_manuscripts_together,
             :send_link_to_apex

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
