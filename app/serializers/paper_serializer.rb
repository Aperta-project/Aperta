class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title
  %i!phases assignees declarations!.each {|relation| has_many relation, embed: :ids, include: true }
  has_many :available_reviewers, embed: :ids, include: true
  has_many :reviewers, embed: :ids, include: true

  def available_reviewers
    object.journal.reviewers
  end
end
