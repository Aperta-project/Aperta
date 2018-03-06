class ManuscriptManagerTemplateSerializer < AuthzSerializer
  attributes :id,
    :paper_type,
    :uses_research_article_reviewer_report,
    :is_preprint_eligible,
    :updated_at
  has_one :journal, embed: :ids
  has_many :phase_templates, embed: :ids, include: true
  has_many :active_papers, embed: :ids

  def active_papers
    object.papers.active
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
