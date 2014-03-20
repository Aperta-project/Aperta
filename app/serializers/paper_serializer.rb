class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title
  %i!phases assignees declarations!.each {|relation| has_many relation, embed: :ids, include: true }
end
