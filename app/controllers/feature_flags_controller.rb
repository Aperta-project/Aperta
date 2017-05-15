# Feature flags represent partially finished features, which are
# concealed in production. Feature flags cannot be created nor
# destroyed by the API; only toggled.
#
class FeatureFlagsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  respond_to :json

  def index
    render json: FeatureFlag.to_hash
  end

  def update
    # must have site admin permission
    raise AuthorizationError unless current_user.site_admin?
    flags = params['feature_flags']
    flags.keys.each do |name|
      FeatureFlag.find(name).update(active: flags[name])
    end

    render json: FeatureFlag.to_hash
  end
end
