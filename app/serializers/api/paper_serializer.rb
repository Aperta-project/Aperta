class Api::PaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :authors, :paper_type, :epub

  def epub
    api_paper_url(object, format: :epub)
  end
end
