class TokenCoauthorSerializer < ActiveModel::Serializer
  attributes :id, :token, :paper_title, :coauthors

  def paper_title
    object.paper.title
  end

  def coauthors
    object.paper.all_authors.map do |author|
      { full_name: author.full_name, affiliation: author.affiliation }
    end
  end
end
