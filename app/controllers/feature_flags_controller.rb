# Feature flags represent partially finished features, which are
# concealed in production. Feature flags cannot be created nor
# destroyed by the API; only toggled.
#
class FeatureFlagsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  respond_to :json

  def index
    respond_with FeatureFlag.all
  end

  def update
    # must have site admin permission
    raise AuthorizationError unless current_user.site_admin?
    flag = FeatureFlag.find(params[:id])
    flag.update active: params[:feature_flag][:active]

    respond_with flag
  end
end
