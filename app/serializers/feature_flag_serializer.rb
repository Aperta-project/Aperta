# FeatureFlags represent unfinished features which are disabled in
# production. See FeatureFlag model for more information.
class FeatureFlagSerializer < ActiveModel::Serializer
  attributes :name, :active
end
