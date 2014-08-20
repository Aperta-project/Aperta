class ManuscriptManagerTemplateSerializer < ActiveModel::Serializer
  attributes :id, :paper_type
  has_one :journal, embed: :ids
  has_many :phase_templates, embed: :ids, include: true
end
