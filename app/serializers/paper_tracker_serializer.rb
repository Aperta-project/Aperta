class PaperTrackerSerializer < ActiveModel::Serializer
  attributes :id, :display_title, :paper_type, :paper_roles, :submitted_at

  def display_title
    object.title || object.short_title
  end

  def submitted_at
    object.created_at
  end
end
