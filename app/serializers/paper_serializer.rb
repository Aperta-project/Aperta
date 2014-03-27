class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :decision, :decision_letter, :authors

  %i!phases assignees declarations figures reviewers!.each do |relation|
    has_many relation, embed: :ids, include: true
  end
  has_one :journal, embed: :ids, include: true

  def authors
    object.authors.to_json
  end
end
