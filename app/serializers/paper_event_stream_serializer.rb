class PaperEventStreamSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :body, :submitted, :paper_type, :status, :updated_at, :event_name
  root :paper

  %i(phases figures author_groups supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: false
  end

  %i(assignees editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: false, root: :users
  end

  has_many :tasks, embed: :ids, polymorphic: true
  has_one :journal, embed: :ids, include: false
  has_one :locked_by, embed: :id, include: false, root: :users

  def status
    object.manuscript.try(:status)
  end

  def event_name
    EventStream.name(object.id)
  end
end
