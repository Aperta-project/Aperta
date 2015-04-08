class DecisionSerializer < ActiveModel::Serializer
  attributes :id, :verdict, :revision_number, :letter
end
