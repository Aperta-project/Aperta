class DecisionSerializer < ActiveModel::Serializer
  attributes :id, :verdict, :revision_number, :letter
  has_many :invitations, embed: :ids, include: true
end
