class ManuscriptManagerTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :paper_type, :template
  has_one :journal, embed: :ids
end
