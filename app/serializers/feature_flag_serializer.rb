class FeatureFlagSerializer < ActiveModel::Serializer
  attributes :id, :name, :active
end
