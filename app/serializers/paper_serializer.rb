class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :decision, :decision_letter, :authors
  attributes :admin_id

  %i!phases assignees declarations figures reviewers!.each do |relation|
    has_many relation, embed: :ids, include: true
  end
  has_one :journal, embed: :ids, include: true

  def admin_id
    object.admin.try(:id)
  end

  def authors
    object.authors
  end
end
