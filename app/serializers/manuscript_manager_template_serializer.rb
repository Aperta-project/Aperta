class ManuscriptManagerTemplateSerializer < ActiveModel::Serializer
  attributes :id,
    :paper_type,
    :uses_research_article_reviewer_report,
    :updated_at
  has_one :journal, embed: :ids
  has_many :phase_templates, embed: :ids, include: true
  has_many :active_papers, embed: :ids

  def active_papers
    object.papers.active
  end
end
