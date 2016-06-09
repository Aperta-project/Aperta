class ManuscriptManagerTemplateSerializer < ActiveModel::Serializer
  attributes :id, :paper_type, :uses_research_article_reviewer_report
  has_one :journal, embed: :ids
  has_many :phase_templates, embed: :ids, include: true
end
