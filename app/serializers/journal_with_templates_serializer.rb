class JournalWithTemplatesSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types
  has_many :manuscript_manager_templates, include: true
end
