class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id
end
