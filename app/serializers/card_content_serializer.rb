class CardContentSerializer < ActiveModel::Serializer
  attributes :id, :ident, :text, :value_type
end
