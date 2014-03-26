class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title
  %i!phases assignees declarations figures reviewers!.each do |relation|
    has_many relation, embed: :ids, include: true
  end
  has_one :journal, embed: :ids, include: true
end
