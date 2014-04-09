class Api::PaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :authors, :paper_type
end
