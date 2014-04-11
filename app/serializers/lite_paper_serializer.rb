class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title

  def paper_id
    id
  end

end
