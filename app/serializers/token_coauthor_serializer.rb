class TokenCoauthorSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :confirmation_state, :paper_title, :coauthors, :journal_logo_url

  def id
    object.token
  end

  def paper_title
    object.paper.title
  end

  def coauthors
    object.paper.all_authors.map do |author|
      { fullName: author.full_name, affiliation: author.affiliation }
    end
  end

  def confirmation_state
    object.co_author_state
  end

  def journal_logo_url
    object.paper.journal.logo_url
  end
end
