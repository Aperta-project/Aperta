class JournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types, :manuscript_css

  # We want to reverse the order of paper_types here so that the oldest paper
  # types appear first so users do not need to dig through tons of types
  # that may not be relevant
  def paper_types
    object.paper_types.reverse
  end
end
