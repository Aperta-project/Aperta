class JournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types, :task_types, :manuscript_css
  has_many :reviewers, embed: :ids, include: true, root: :users

  def task_types
    Journal::VALID_TASK_TYPES
  end

  def reviewers
    object.reviewers.includes(:affiliations)
  end
end
